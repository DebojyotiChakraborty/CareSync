-- ============================================================================
-- Migration 044: Authentication & Role-Separation Security Hardening
-- ----------------------------------------------------------------------------
-- Complements 043_biometric_emergency_hardening.sql. Apply AFTER 043.
--
-- This migration is intentionally SCOPED so it does NOT overlap with 043:
--   * 043 already handles: profiles anon-read ("Authenticated can view
--     profiles"), emergency_access_logs INSERT actor-binding, patient_embeddings
--     RLS, biometric RPC grants, get_emergency_data. 044 does NOT touch those.
--
-- 044 covers what remains in the sign-in / role-separation audit:
--   1. Block users from changing their own profiles.role (privilege escalation)
--   2. Pin search_path on the SECURITY DEFINER functions used in auth/RLS
--   3. Lock the face_embeddings read leak (USING(true)) to the owner
--   4. Remove the biometric_profiles "System select profiles" USING(true) leak
--   5. Make audit_log / two_factor_codes inserts un-forgeable + audit_log immutable
--   6. Scope vitals emergency reads to an active grant (guarded: only runs if the
--      objects it needs exist, because this DB is not fully in sync with the repo)
--
-- NOTE — this DB is out of sync with the repo migrations (040 not applied, 005's
-- profiles UPDATE policy absent; the live UPDATE policy is 002's
-- `profiles_update_own`). 044 therefore does NOT drop any profiles UPDATE policy
-- (the role lock is enforced by a trigger, which is policy-independent).
--
-- DESIGN RISKS NOT CHANGED HERE (need a product decision / an admin workflow):
--   * handle_new_user() still trusts the client signup role, so a NEW account can
--     still self-select doctor/pharmacist at creation. (1) below only stops
--     escalation AFTER creation. Gate signup elevation behind admin review.
--   * submit_kyc_secure() still auto-approves KYC (no reviewer exists); only its
--     search_path is hardened here.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. PREVENT SELF-ESCALATION OF profiles.role  (CRITICAL)
--    RLS WITH CHECK cannot see the OLD row, so use a BEFORE UPDATE trigger.
--    Only blocks a user changing the role on THEIR OWN row; service-role /
--    SECURITY DEFINER contexts (auth.uid() IS NULL, e.g. the signup trigger)
--    and a future admin path are unaffected. This is enforced regardless of
--    which UPDATE policy is active, so no policy change is required.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.prevent_role_self_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF auth.uid() = OLD.id AND NEW.role IS DISTINCT FROM OLD.role THEN
        RAISE EXCEPTION 'Changing your own role is not permitted';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_no_role_self_change ON public.profiles;
CREATE TRIGGER trg_profiles_no_role_self_change
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.prevent_role_self_change();

-- ----------------------------------------------------------------------------
-- 2. PIN search_path ON SECURITY DEFINER FUNCTIONS USED IN AUTH/RLS  (HIGH)
--    get_user_role() is the most important — it decides the role inside the
--    role-gated RLS policies. CREATE OR REPLACE is a no-op-safe upgrade.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT role INTO user_role FROM public.profiles WHERE id = user_id;
    RETURN user_role;
END;
$$;

-- handle_new_user(): pin search_path AND stop the ON CONFLICT path from ever
-- rewriting an existing profile's role (defense in depth against re-signup).
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, phone, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'phone', NULL),
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
        COALESCE(NEW.raw_user_meta_data->>'role', 'patient')
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        phone = COALESCE(EXCLUDED.phone, profiles.phone),
        full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
        -- role deliberately NOT rewritten here
        updated_at = NOW();
    RETURN NEW;
END;
$$;

-- submit_kyc_secure(): harden search_path only (behaviour unchanged). CREATE OR
-- REPLACE also (re)creates it if 039 was never applied to this DB.
CREATE OR REPLACE FUNCTION public.submit_kyc_secure(
    p_full_name TEXT,
    p_date_of_birth DATE,
    p_id_document_url TEXT,
    p_selfie_url TEXT,
    p_additional_documents TEXT[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    INSERT INTO public.kyc_verifications (
        user_id, full_name, date_of_birth, id_document_url, selfie_url,
        additional_documents, kyc_status, created_at, updated_at
    )
    VALUES (
        auth.uid(), p_full_name, p_date_of_birth, p_id_document_url, p_selfie_url,
        to_jsonb(p_additional_documents), 'verified', NOW(), NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        date_of_birth = EXCLUDED.date_of_birth,
        id_document_url = EXCLUDED.id_document_url,
        selfie_url = EXCLUDED.selfie_url,
        additional_documents = EXCLUDED.additional_documents,
        kyc_status = 'verified',
        updated_at = NOW();
END;
$$;
GRANT EXECUTE ON FUNCTION public.submit_kyc_secure(TEXT, DATE, TEXT, TEXT, TEXT[]) TO authenticated;

-- ----------------------------------------------------------------------------
-- 3. LOCK THE face_embeddings READ LEAK TO THE OWNER  (HIGH)
--    Live DB has "Embeddings select auth" USING (true) -> every authenticated
--    user can read every user's 512-d face vectors. Matching runs through
--    SECURITY DEFINER RPCs (owner privilege, bypass RLS), so owner-only read
--    does not break identification.
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Embeddings select auth" ON public.face_embeddings;
CREATE POLICY "Embeddings select self"
    ON public.face_embeddings FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.biometric_profiles bp
            WHERE bp.id = face_embeddings.biometric_profile_id
              AND bp.user_id = auth.uid()
        )
    );

-- ----------------------------------------------------------------------------
-- 4. REMOVE THE biometric_profiles BLANKET READ  (HIGH)
--    "System select profiles" USING (true) overrides the adjacent
--    "Profiles view self" self-only policy. Drop the blanket read; self-access
--    remains via "Profiles view self".
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "System select profiles" ON public.biometric_profiles;

-- ----------------------------------------------------------------------------
-- 5. MAKE audit_log / two_factor_codes INSERTS UN-FORGEABLE + audit_log IMMUTABLE
--    (MEDIUM)  Both used WITH CHECK (true). Bind the actor to auth.uid().
--    (emergency_access_logs INSERT is already handled by migration 043.)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "System can insert audit logs" ON public.audit_log;
CREATE POLICY "Users can insert their own audit logs"
    ON public.audit_log FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "System can insert 2FA codes" ON public.two_factor_codes;
CREATE POLICY "Users can insert their own 2FA codes"
    ON public.two_factor_codes FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.prevent_audit_log_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'audit_log rows are immutable';
END;
$$;

DROP TRIGGER IF EXISTS trg_audit_log_immutable ON public.audit_log;
CREATE TRIGGER trg_audit_log_immutable
    BEFORE UPDATE OR DELETE ON public.audit_log
    FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_log_changes();

-- ----------------------------------------------------------------------------
-- 6. SCOPE VITALS EMERGENCY READS TO AN ACTIVE GRANT  (HIGH) -- GUARDED
--    Owner access is covered by the existing "Patients can manage their own
--    vitals" policy; this ADDS a verified-emergency read path. Guarded because
--    this DB may be missing has_emergency_access() (migration 009) and/or the
--    040 USING(true) policy. Only runs when has_emergency_access() exists.
-- ----------------------------------------------------------------------------
DO $$
BEGIN
    -- Remove the over-broad 040 policy if it happens to be present.
    DROP POLICY IF EXISTS "First responders can view vitals in emergency" ON public.vitals;

    IF to_regprocedure('public.has_emergency_access(uuid,uuid)') IS NOT NULL THEN
        DROP POLICY IF EXISTS "Emergency vitals view" ON public.vitals;
        CREATE POLICY "Emergency vitals view"
            ON public.vitals FOR SELECT
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM public.patients p
                    WHERE p.id = vitals.patient_id
                      AND public.has_emergency_access(auth.uid(), p.user_id)
                )
            );
    ELSE
        RAISE NOTICE 'has_emergency_access() missing (migration 009 not applied); skipped "Emergency vitals view". Apply 009 then re-run this block.';
    END IF;
END $$;

-- ============================================================================
-- END migration 044
-- ============================================================================
