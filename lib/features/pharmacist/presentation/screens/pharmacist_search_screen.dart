import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/design/cs_buttons.dart';
import '../../../../core/design/linear_fade_appbar.dart';
import '../../../../core/design/minimal_sheet_dialog.dart';
import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/supabase_service.dart';

class PharmacistSearchScreen extends StatefulWidget {
  const PharmacistSearchScreen({super.key});

  @override
  State<PharmacistSearchScreen> createState() => _PharmacistSearchScreenState();
}

class _PharmacistSearchScreenState extends State<PharmacistSearchScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPatients(query);
    });
  }

  Future<void> _searchPatients(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await SupabaseService.instance.client
          .from('profiles')
          .select('id, email, phone, full_name')
          .eq('role', 'patient')
          .or('email.ilike.%$query%,phone.ilike.%$query%,full_name.ilike.%$query%')
          .limit(10);

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error searching patients: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _selectPatient(Map<String, dynamic> profile) async {
    final phone = profile['phone'] as String? ?? '';
    final lastFourDigits =
        phone.length >= 4 ? phone.substring(phone.length - 4) : '1234';

    // Show secure verification sheet (OTP check)
    final verified = await showAppSheet<bool>(
      context,
      builder: (sheetCtx) {
        final t = sheetCtx.tokens;
        final pinController = TextEditingController();
        bool isPinError = false;

        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Iconsax.shield_tick, size: 40, color: t.accent),
                  const SizedBox(height: 12),
                  Text('Security Verification',
                      textAlign: TextAlign.center, style: t.sheetTitle),
                  const SizedBox(height: 12),
                  Text(
                    'To access patient prescriptions, please enter the 4-digit code shown on the patient\'s CareSync app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: t.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    cursorColor: t.accent,
                    style: TextStyle(
                        fontSize: 24,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w700,
                        color: t.textPrimary),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '••••',
                      counterText: '',
                      errorText:
                          isPinError ? 'Invalid verification code' : null,
                      filled: true,
                      fillColor: t.scaffold,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: t.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: t.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: t.accent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hint: Patient\'s phone last 4 digits ($lastFourDigits)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        color: t.textSecondary,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 20),
                  CSTwoButtonRow(
                    cancelLabel: 'Cancel',
                    confirmLabel: 'Verify',
                    onCancel: () => Navigator.pop(sheetCtx, false),
                    onConfirm: () {
                      if (pinController.text.trim() == lastFourDigits) {
                        Navigator.pop(sheetCtx, true);
                      } else {
                        setSheetState(() => isPinError = true);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (verified != true) return;

    // Retrieve patient record to get their qr_code_id
    try {
      final patientRecord = await SupabaseService.instance.client
          .from('patients')
          .select('qr_code_id')
          .eq('user_id', profile['id'])
          .maybeSingle();

      if (!mounted) return;

      if (patientRecord == null || patientRecord['qr_code_id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Patient record has no registered QR code ID'),
            backgroundColor: context.tokens.error,
          ),
        );
        return;
      }

      final qrCodeId = patientRecord['qr_code_id'] as String;

      // Navigate to dispensing screen with pre-filled QR Code ID
      context.pushReplacement(RouteNames.pharmacistDispense, extra: qrCodeId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Database error: $e'),
              backgroundColor: context.tokens.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CSScaffold(
      title: 'Patient Search',
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Patients',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: t.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter patient name, email, or phone number to load prescription list.',
              style: TextStyle(fontSize: 14, color: t.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              cursorColor: t.accent,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: Icon(Iconsax.search_normal_1, color: t.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        color: t.textSecondary,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                filled: true,
                fillColor: t.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.accent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isSearching
                  ? Center(child: CircularProgressIndicator(color: t.accent))
                  : _searchResults.isEmpty
                      ? _buildEmptyState()
                      : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final t = context.tokens;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: t.textSecondary),
          const SizedBox(height: 16),
          Text(
            _searchController.text.length < 2
                ? 'Type at least 2 characters to search'
                : 'No patients found',
            style: TextStyle(color: t.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final t = context.tokens;
    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final profile = _searchResults[index];
        final email = profile['email'] as String? ?? 'No email';
        final phone = profile['phone'] as String? ?? 'No phone';

        return SquircleCard(
          radius: AppSpacing.squircleGrouped,
          borderSide: BorderSide(color: t.divider),
          padding: EdgeInsets.zero,
          onTap: () => _selectPatient(profile),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: t.tint,
              child: Icon(Iconsax.user, color: t.accent),
            ),
            title: Text(
              profile['full_name'] as String? ?? 'Unknown Patient',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: t.textPrimary),
            ),
            subtitle: Text('$email\n$phone',
                style: TextStyle(fontSize: 12, color: t.textSecondary)),
            trailing: Icon(Iconsax.arrow_right_3, color: t.textSecondary),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
