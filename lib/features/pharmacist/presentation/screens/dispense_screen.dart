import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/design/circular_icon_button.dart';
import '../../../../core/design/confirm_sheet.dart';
import '../../../../core/design/cs_buttons.dart';
import '../../../../core/design/linear_fade_appbar.dart';
import '../../../../core/design/minimal_sheet_dialog.dart';
import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/biometric_service.dart';
import '../../../../services/custom_biometric_service.dart';

class DispenseScreen extends ConsumerStatefulWidget {
  final String? initialQrCodeId;
  const DispenseScreen({super.key, this.initialQrCodeId});

  @override
  ConsumerState<DispenseScreen> createState() => _DispenseScreenState();
}

class _DispenseScreenState extends ConsumerState<DispenseScreen> {
  Map<String, dynamic>? _patient;
  List<Map<String, dynamic>> _prescriptions = [];
  Map<String, bool> _selectedItems = {};
  bool _isLoading = false;
  bool _isScanning = true;

  static const _controlledSubstances = [
    'morphine',
    'fentanyl',
    'oxycodone',
    'codeine',
    'tramadol',
    'xanax',
    'diazepam',
    'adderall',
    'ritalin',
    'methadone',
    'vicodin',
    'hydrocodone',
    'buprenorphine',
    'alprazolam',
    'lorazepam',
  ];

  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQrCodeId != null) {
      _isScanning = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPatientPrescriptions(widget.initialQrCodeId!);
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? context.tokens.error : context.tokens.accent,
      ),
    );
  }

  Future<void> _loadPatientPrescriptions(String qrCodeId) async {
    setState(() {
      _isLoading = true;
      _isScanning = false;
    });

    try {
      final patient = await SupabaseService.instance.client
          .from('patients')
          .select('id, user_id, profiles!inner(full_name, email)')
          .eq('qr_code_id', qrCodeId)
          .maybeSingle();

      if (patient == null) {
        if (mounted) {
          _snack('Patient not found', error: true);
          setState(() => _isScanning = true);
        }
        return;
      }

      final prescriptions = await SupabaseService.instance.client
          .from('prescriptions')
          .select('''
            *,
            prescription_items(*),
            doctor:profiles!doctor_id(full_name)
          ''')
          .eq('patient_id', patient['id'])
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final newSelectedItems = <String, bool>{};
      for (final rx in prescriptions) {
        final items = rx['prescription_items'] as List? ?? [];
        for (final item in items) {
          final itemId = item['id'] as String;
          final isDispensed = item['is_dispensed'] as bool? ?? false;
          if (!isDispensed) {
            newSelectedItems[itemId] = true;
          }
        }
      }

      setState(() {
        _patient = patient;
        _prescriptions = List<Map<String, dynamic>>.from(prescriptions);
        _selectedItems = newSelectedItems;
      });
    } catch (e) {
      if (mounted) {
        _snack('Error: $e', error: true);
        setState(() => _isScanning = true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isLoading || !_isScanning) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final value = barcode!.rawValue!;

    if (value.contains('/emergency/')) {
      final uri = Uri.parse(value);
      final qrCodeId = uri.pathSegments.last;
      _loadPatientPrescriptions(qrCodeId);
    } else {
      _loadPatientPrescriptions(value);
    }
  }

  Future<void> _dispensePrescription(Map<String, dynamic> prescription) async {
    final items = prescription['prescription_items'] as List? ?? [];
    final rxItemIdList = items.map((i) => i['id'] as String).toList();

    final selectedItemIds =
        rxItemIdList.where((id) => _selectedItems[id] == true).toList();

    if (selectedItemIds.isEmpty) {
      _snack('Please select at least one medication to dispense');
      return;
    }

    final notesController = TextEditingController();
    final confirmed = await showAppSheet<bool>(
      context,
      builder: (ctx) {
        final t = ctx.tokens;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Confirm Dispensing',
                  textAlign: TextAlign.center, style: t.sheetTitle),
              const SizedBox(height: 12),
              Text(
                'Dispense ${selectedItemIds.length} selected medication(s) for prescription:\n"${prescription['diagnosis'] ?? 'No diagnosis'}"?',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 2,
                cursorColor: t.accent,
                decoration: InputDecoration(
                  labelText: 'Dispense Notes (Optional)',
                  hintText:
                      'e.g., Generic brand substituted, counseling provided...',
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
              const SizedBox(height: 20),
              CSTwoButtonRow(
                cancelLabel: 'Cancel',
                confirmLabel: 'Dispense',
                onCancel: () => Navigator.pop(ctx, false),
                onConfirm: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    // Controlled Substance Check & Patient Biometric Verification
    final isControlledPrescription = items.any((item) {
      final itemId = item['id'] as String;
      if (!selectedItemIds.contains(itemId)) return false;

      final name = (item['medicine_name'] as String? ?? '').toLowerCase();
      return _controlledSubstances.any((substance) => name.contains(substance));
    });

    if (isControlledPrescription) {
      if (!mounted) return;
      final confirmVerify = await showConfirmSheet(
        context,
        icon: Iconsax.security_safe,
        title: 'Controlled Substance',
        message:
            'This prescription contains controlled substances (narcotics/stimulants). '
            'By law, biometric facial verification of the patient is required before dispensing.\n\n'
            'Please scan the patient\'s face to proceed.',
        confirmLabel: 'Scan Patient Face',
      );

      if (!confirmVerify) return;

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        if (mounted) {
          _snack('Facial scan cancelled. Dispensation aborted.', error: true);
        }
        return;
      }

      setState(() => _isLoading = true);

      try {
        final identifyResult =
            await CustomBiometricService.instance.identifyPatientDetailed(
          File(image.path),
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (identifyResult.status == BiometricResultStatus.success &&
            identifyResult.patientId != null) {
          final expectedUserId = _patient!['user_id'] as String?;
          final currentPatientName =
              _patient!['profiles']['full_name'] as String? ?? 'Unknown';

          if (identifyResult.patientId == expectedUserId) {
            _snack(
              'Patient Biometric Verified: $currentPatientName (${identifyResult.confidence?.toStringAsFixed(1)}% match)',
            );
          } else {
            // Patient mismatch!
            await showAlertSheet(
              context,
              icon: Iconsax.warning_2,
              title: 'Security Mismatch',
              message: 'Biometric verification failed.\n\n'
                  'Expected Patient: $currentPatientName\n'
                  'Identified Patient: ${identifyResult.fullName ?? "Unknown"}\n\n'
                  'The dispensing of controlled substances has been blocked for patient safety.',
              buttonLabel: 'Close',
            );
            return;
          }
        } else {
          final errMessage =
              CustomBiometricService.instance.mapStatusToErrorMessage(
            identifyResult.status,
            identifyResult.errorMessage,
            errorCode: identifyResult.errorCode,
          );
          await showAlertSheet(
            context,
            icon: Iconsax.warning_2,
            title: 'Verification Failed',
            message: 'Could not verify patient\'s biometric identity.\n\n'
                'Detail: $errMessage\n\n'
                'Dispensing controlled substances is legally restricted without verified biometric authentication.',
            buttonLabel: 'Close',
          );
          return;
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _snack('Biometric microservice query error: $e', error: true);
        }
        return;
      }
    }

    // Biometric Verification for Pharmacist
    try {
      final isBioAvailable =
          await BiometricService.instance.isBiometricAvailable();
      if (isBioAvailable) {
        final authenticated = await BiometricService.instance.authenticate(
          reason:
              'Scan your biometric to authorize this medication dispensation',
          biometricOnly: false,
        );
        if (!authenticated) {
          if (mounted) {
            _snack('Biometric authentication failed. Dispensation aborted.',
                error: true);
          }
          return;
        }
      } else {
        if (!mounted) return;
        final passcodeConfirmed = await showConfirmSheet(
          context,
          icon: Iconsax.finger_scan,
          title: 'Biometric Offline',
          message:
              'Biometrics are not set up or supported on this device. '
              'Do you want to authorize this dispensation using your session credentials?',
          confirmLabel: 'Authorize',
          cancelLabel: 'Abort',
        );
        if (!passcodeConfirmed) return;
      }
    } catch (e) {
      if (mounted) {
        _snack('Verification error: $e', error: true);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.instance.recordDispensing(
        prescriptionId: prescription['id'] as String,
        patientId: _patient!['id'] as String,
        notes: notesController.text.trim(),
        itemsDispensed: selectedItemIds,
      );

      for (final itemId in selectedItemIds) {
        await SupabaseService.instance.client
            .from('prescription_items')
            .update({'is_dispensed': true}).eq('id', itemId);
      }

      final allItems = prescription['prescription_items'] as List? ?? [];
      final undispensedItems = allItems.where((item) {
        final itemId = item['id'] as String;
        final isNowDispensed = selectedItemIds.contains(itemId);
        final wasAlreadyDispensed = item['is_dispensed'] as bool? ?? false;
        return !isNowDispensed && !wasAlreadyDispensed;
      });

      if (undispensedItems.isEmpty) {
        await SupabaseService.instance.client
            .from('prescriptions')
            .update({'status': 'completed'}).eq('id', prescription['id']);
      }

      if (mounted) {
        _snack('Medications dispensed successfully');

        final qrCodeId = await SupabaseService.instance.client
            .from('patients')
            .select('qr_code_id')
            .eq('id', _patient!['id'])
            .single();
        _loadPatientPrescriptions(qrCodeId['qr_code_id'] as String);
      }
    } catch (e) {
      if (mounted) {
        _snack('Error: $e', error: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetScan() {
    setState(() {
      _patient = null;
      _prescriptions = [];
      _selectedItems = {};
      _isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final topInset = MediaQuery.of(context).padding.top + AppSpacing.appBarHeight;

    final Widget content = _isScanning
        ? _buildScanner()
        : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildPrescriptionList();

    return Scaffold(
      backgroundColor: t.scaffold,
      body: Stack(
        children: [
          // Scanner is full-bleed; other states sit below the fade bar.
          _isScanning
              ? content
              : Padding(padding: EdgeInsets.only(top: topInset), child: content),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearFadeAppBar(
              title: 'Dispense Medication',
              actions: [
                if (_patient != null)
                  CircularIconButton(
                    icon: Iconsax.scan_barcode,
                    onTap: _resetScan,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    final t = context.tokens;
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: t.accent, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Scan patient\'s QR code',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionList() {
    final t = context.tokens;
    final dateFormat = DateFormat('MMM d, yyyy');
    final profileData = _patient!['profiles'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient info
          SquircleCard(
            radius: AppSpacing.squircleGrouped,
            color: t.tint,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.user, color: t.accent, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient',
                          style: TextStyle(fontSize: 12, color: t.accent)),
                      Text(
                        profileData['full_name'] as String? ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary,
                        ),
                      ),
                      if (profileData['email'] != null)
                        Text(
                          profileData['email'] as String,
                          style:
                              TextStyle(fontSize: 13, color: t.textSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Prescriptions
          Text(
            'Active Prescriptions (${_prescriptions.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_prescriptions.isEmpty)
            SquircleCard(
              radius: AppSpacing.squircleGrouped,
              borderSide: BorderSide(color: t.divider),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Iconsax.tick_circle, size: 48, color: t.accent),
                  const SizedBox(height: 12),
                  Text(
                    'No active prescriptions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: t.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All prescriptions have been dispensed',
                    style: TextStyle(color: t.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_prescriptions.length, (index) {
              final rx = _prescriptions[index];
              final items = rx['prescription_items'] as List? ?? [];
              final doctor = rx['doctor'] as Map<String, dynamic>?;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SquircleCard(
                  radius: AppSpacing.squircleGrouped,
                  borderSide: BorderSide(color: t.divider),
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rx['diagnosis'] as String? ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: t.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dr. ${doctor?['full_name'] ?? 'Unknown'} • ${dateFormat.format(DateTime.parse(rx['created_at'] as String))}',
                                  style: TextStyle(
                                      fontSize: 13, color: t.textSecondary),
                                ),
                              ],
                            ),
                            if (items.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Divider(height: 1, color: t.divider),
                              const SizedBox(height: 12),
                              ...items.map((item) {
                                final itemId = item['id'] as String;
                                final isDispensed =
                                    item['is_dispensed'] as bool? ?? false;

                                if (isDispensed) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            size: 20, color: t.accent),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${item['medicine_name']} - ${item['dosage']}',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: t.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Dispensed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: t.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final isControlled =
                                    _controlledSubstances.any((substance) =>
                                        (item['medicine_name'] as String? ?? '')
                                            .toLowerCase()
                                            .contains(substance));

                                return CheckboxListTile(
                                  value: _selectedItems[itemId] ?? false,
                                  activeColor: t.accent,
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item['medicine_name']} - ${item['dosage']}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: t.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isControlled)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: t.error
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: t.error
                                                    .withValues(alpha: 0.2)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Iconsax.security_safe,
                                                  color: t.error, size: 10),
                                              const SizedBox(width: 4),
                                              Text(
                                                'CONTROLLED',
                                                style: t.monoMeta.copyWith(
                                                  color: t.error,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    '${item['frequency']} for ${item['duration'] ?? "N/A"}',
                                    style: TextStyle(
                                        fontSize: 13, color: t.textSecondary),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedItems[itemId] = val ?? false;
                                    });
                                  },
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                      // Dispense button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.tint,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(AppSpacing.squircleGrouped),
                          ),
                        ),
                        child: CSPrimaryButton(
                          label: 'Dispense Selected',
                          icon: Icons.check_rounded,
                          onPressed: _isLoading
                              ? null
                              : () => _dispensePrescription(rx),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
