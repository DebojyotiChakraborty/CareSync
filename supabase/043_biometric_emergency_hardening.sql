-- ============================================================================
-- 043_biometric_emergency_hardening.sql
-- Security hardening for the biometric / emergency-access flow.
-- Addresses the anon-callable biometric oracle, the anon-readable user directory,
-- forgeable emergency audit inserts, unprotected raw embeddings, and a broken
-- emergency audit insert (missing patient_id).
-- Apply after 042 in the Supabase SQL editor.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Revoke EXECUTE on face-matching RPCs from anon / PUBLIC.
--    These SECURITY DEFINER functions returned patient_id / full_name / qr_code_id
--    for any embedding within a client-supplied distance. Because they defaulted to
--    PUBLIC (which anon inherits) and the anon key is embedded in the public emergency
--    web page, anyone could enumerate the entire patient population. They are only ever
--    meant to be invoked by the biometric API (service_role, which bypasses grants) or,
--    at most, authenticated app sessions. We revoke from PUBLIC + anon and re-grant to
--    authenticated so no unauthenticated caller can reach them.
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    fn RECORD;
BEGIN
    FOR fn IN
        SELECT p.oid::regprocedure AS sig
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
          AND p.proname IN (
              'match_patient_by_face',
              'match_patient_by_face_multi',
              'match_patient_by_face_consensus',
              'detect_duplicate_biometrics'
          )
    LOOP
        EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC;', fn.sig);
        EXECUTE format('REVOKE ALL ON FUNCTION %s FROM anon;', fn.sig);
        EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated;', fn.sig);
        EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO service_role;', fn.sig);
    END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 2. Stop anon from reading the entire user directory.
--    The "Public profiles are viewable by everyone" policy used USING (TRUE) with no
--    role clause, so the anon role could SELECT every profile's email / phone / name /
--    role. Scope the read to authenticated sessions only. (Column/row scoping to reduce
--    what authenticated users can see is a follow-up.)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Authenticated can view profiles"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (TRUE);

-- ----------------------------------------------------------------------------
-- 3. Prevent forged emergency audit rows.
--    The INSERT policy used WITH CHECK (true), letting any authenticated user write
--    audit entries attributing access to arbitrary providers/patients with a forged
--    status. Bind the actor to auth.uid(). (The edge function inserts via service_role,
--    which bypasses RLS, so QR-web logging is unaffected.)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Authenticated users can insert emergency access logs" ON emergency_access_logs;
CREATE POLICY "Users can only log their own emergency access"
    ON emergency_access_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (accessed_by_user_id = auth.uid());

-- ----------------------------------------------------------------------------
-- 4. Enable RLS on the raw biometric embedding store (defense in depth).
--    patient_embeddings held raw 512-d ArcFace vectors with RLS never enabled, so any
--    direct PostgREST query could read/write all templates. The identify path runs through
--    SECURITY DEFINER RPCs (owner privilege) and the biometric API uses service_role, both
--    of which bypass RLS, so enabling RLS with an owner-only policy does not break matching.
-- ----------------------------------------------------------------------------
ALTER TABLE patient_embeddings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Owners can read their own embeddings" ON patient_embeddings;
CREATE POLICY "Owners can read their own embeddings"
    ON patient_embeddings
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM patients pt
            WHERE pt.id = patient_embeddings.patient_id
              AND pt.user_id = auth.uid()
        )
    );
-- No INSERT/UPDATE/DELETE policy for authenticated: enrollment is written by the biometric
-- API via service_role (bypasses RLS). Direct client writes are denied by default.

-- ----------------------------------------------------------------------------
-- 5. Make get_emergency_data return patient_id so emergency access can actually be logged.
--    The edge function referenced data.patient_id (previously undefined), so every web QR
--    access was recorded as an unlogged/failed insert. Return the patient's profile id.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_emergency_data(p_qr_code_id TEXT)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'patient_id', pr.id,
        'patient', jsonb_build_object(
            'full_name', pr.full_name,
            'blood_type', p.blood_type,
            'emergency_contact', p.emergency_contact
        ),
        'conditions', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'type', mc.condition_type,
                    'description', mc.description,
                    'severity', mc.severity
                )
            ), '[]'::jsonb)
            FROM medical_conditions mc
            WHERE mc.patient_id = p.id AND mc.is_public = TRUE
        ),
        'medications', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'medicine', pi.medicine_name,
                    'dosage', pi.dosage,
                    'frequency', pi.frequency
                )
            ), '[]'::jsonb)
            FROM prescription_items pi
            JOIN prescriptions rx ON pi.prescription_id = rx.id
            WHERE rx.patient_id = p.id
                AND rx.is_public = TRUE
                AND rx.status = 'active'
        )
    ) INTO result
    FROM patients p
    JOIN profiles pr ON p.user_id = pr.id
    WHERE p.qr_code_id = p_qr_code_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
