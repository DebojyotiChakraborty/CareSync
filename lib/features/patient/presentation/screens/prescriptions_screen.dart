import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/design/cs_buttons.dart';
import '../../../../core/design/linear_fade_appbar.dart';
import '../../../../core/design/minimal_sheet_dialog.dart';
import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routing/route_names.dart';
import '../../models/prescription.dart';
import '../../providers/patient_provider.dart';

class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final prescriptions = ref.watch(patientPrescriptionsProvider);

    return CSScaffold(
      title: 'Prescriptions',
      actions: [
        IconButton(
          icon: Icon(Iconsax.add_circle, size: 22, color: t.accent),
          onPressed: () => context.push(RouteNames.patientAddPrescription),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.patientAddPrescription),
        icon: const Icon(Iconsax.add, size: 20),
        label: const Text('Add New',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        backgroundColor: t.accent,
        foregroundColor: t.accentOn,
        elevation: 0,
      ),
      body: prescriptions.when(
        data: (list) {
          if (list.isEmpty) return _buildEmptyState(context);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(patientPrescriptionsProvider),
            color: t.accent,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  PrescriptionCard(prescription: list[index]),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: t.accent)),
        error: (e, _) => _buildErrorState(context, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.card,
                shape: BoxShape.circle,
                border: Border.all(color: t.divider),
              ),
              child: Icon(Iconsax.document_text, size: 40, color: t.textSecondary),
            ),
            const SizedBox(height: 18),
            Text(
              'No Prescriptions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: t.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first prescription to track your medications and medical history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 36, color: t.error),
          const SizedBox(height: 14),
          Text('Failed to load data',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: t.textPrimary)),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => ref.invalidate(patientPrescriptionsProvider),
            child: Text('Retry',
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: t.accent)),
          ),
        ],
      ),
    );
  }
}

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionCard({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dateFormat = DateFormat('MMM d, yyyy');
    final status = prescription.computedStatus;
    final doctorName = prescription.displayDoctorName;
    final doctorInitial = doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D';

    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      padding: EdgeInsets.zero,
      onTap: () => _showDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Doctor Info + Status Badge + Type Badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: t.tint,
                      child: Text(
                        doctorInitial,
                        style: TextStyle(
                          color: t.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: t.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            [
                              dateFormat.format(prescription.prescriptionDate ?? prescription.createdAt),
                              if (prescription.displayClinicName != null && prescription.displayClinicName!.trim().isNotEmpty)
                                prescription.displayClinicName!.trim(),
                            ].join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusBadge(status: status),
                        if (prescription.prescriptionType != null && prescription.prescriptionType!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            prescription.prescriptionType!.replaceAll('_', ' ').toUpperCase(),
                            style: t.monoMeta.copyWith(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: t.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Diagnosis Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: t.scaffold,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DIAGNOSIS',
                              style: t.monoMeta.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: t.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              prescription.displayDiagnosis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: t.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (prescription.validUntil != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'VALID UNTIL',
                              style: t.monoMeta.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: t.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateFormat.format(prescription.validUntil!),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: t.textPrimary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // 3. Medications
                if (prescription.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'PRESCRIBED MEDICATIONS',
                    style: t.monoMeta.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: t.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prescription.items.take(3).map((item) {
                      final instructionLine = [
                        if (item.frequency.isNotEmpty) item.frequency,
                        if (item.duration != null && item.duration!.trim().isNotEmpty) item.duration!.trim(),
                        if (item.foodTiming != null && item.foodTiming!.trim().isNotEmpty) item.foodTiming!.trim(),
                      ].join(' • ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: t.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: item.medicineName,
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: t.textPrimary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' (${item.dosage})',
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: t.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (instructionLine.isNotEmpty || (item.instructions != null && item.instructions!.trim().isNotEmpty))
                                    const SizedBox(height: 2),
                                  if (instructionLine.isNotEmpty)
                                    Text(
                                      instructionLine,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: t.textSecondary,
                                      ),
                                    ),
                                  if (item.instructions != null && item.instructions!.trim().isNotEmpty)
                                    Text(
                                      'Directives: ${item.instructions!.trim()}',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                        color: t.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (prescription.items.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '+ ${prescription.items.length - 3} more',
                        style: TextStyle(
                          fontSize: 11,
                          color: t.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],

                // 4. Clinical Notes
                () {
                  final notes = prescription.doctorNotes ?? prescription.patientNotes ?? prescription.notes;
                  if (notes == null || notes.trim().isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.scaffold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Iconsax.note_1, size: 12, color: t.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              notes,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: t.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }(),
              ],
            ),
          ),

          // 5. Footer Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.document_text, size: 14, color: t.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      prescription.items.length.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: t.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'items',
                      style: TextStyle(
                        color: t.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      prescription.isPublic ? Iconsax.global : Iconsax.security_user,
                      size: 12,
                      color: t.textSecondary,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: t.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: t.accent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showAppSheet<void>(
      context,
      showHandle: false,
      builder: (_) => _PrescriptionDetailsSheet(prescription: prescription),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PrescriptionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Color color;
    switch (status) {
      case PrescriptionStatus.active:
        color = t.accent;
        break;
      case PrescriptionStatus.expired:
        color = t.error;
        break;
      case PrescriptionStatus.upcoming:
        color = t.accent;
        break;
      case PrescriptionStatus.completed:
      case PrescriptionStatus.cancelled:
        color = t.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: t.monoMeta.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _PrescriptionDetailsSheet extends StatelessWidget {
  final Prescription prescription;

  const _PrescriptionDetailsSheet({required this.prescription});

  Future<void> _launchPdf(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      } catch (e) {
        launched = false;
      }

      if (!launched) {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not open PDF';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error opening PDF: $e'),
          backgroundColor: context.tokens.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dateFormat = DateFormat('MMMM d, yyyy');

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.78,
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prescription Details', style: t.sheetTitle),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 20, color: t.textSecondary),
                  style: IconButton.styleFrom(
                    backgroundColor: t.scaffold,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: t.divider),

          // Scrollable Body
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                // 1. core Details
                _buildSectionLabel(context, 'MEDICAL DETAILS'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        'Diagnosis',
                        prescription.displayDiagnosis,
                        icon: Iconsax.heart,
                        isBold: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: t.divider),
                      ),
                      _buildInfoRow(
                        context,
                        'Doctor',
                        prescription.displayDoctorName,
                        subtitle: prescription.displayClinicName,
                        icon: Iconsax.user,
                      ),
                      if (prescription.doctorDetails?.specialization != null || prescription.doctorDetails?.medicalRegistrationNumber != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (prescription.doctorDetails?.specialization != null && prescription.doctorDetails!.specialization!.trim().isNotEmpty)
                                Text(
                                  prescription.doctorDetails!.specialization!.trim(),
                                  style: TextStyle(color: t.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              if (prescription.doctorDetails?.medicalRegistrationNumber != null && prescription.doctorDetails!.medicalRegistrationNumber!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Registration No: ${prescription.doctorDetails!.medicalRegistrationNumber!.trim()}',
                                  style: TextStyle(color: t.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Validity
                _buildSectionLabel(context, 'VALIDITY'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(context, 'Prescribed On', dateFormat.format(prescription.prescriptionDate ?? prescription.createdAt)),
                      ),
                      Container(width: 1, height: 32, color: t.divider),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: _buildMetaItem(
                            context,
                            'Valid Until',
                            prescription.validUntil != null ? dateFormat.format(prescription.validUntil!) : 'N/A',
                            isAlert: prescription.validUntil?.isBefore(DateTime.now()) ?? false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Medications List
                _buildSectionLabel(context, 'MEDICATIONS (${prescription.items.length})'),
                if (prescription.items.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('No medications listed', style: TextStyle(color: t.textSecondary)),
                    ),
                  )
                else
                  ...prescription.items.asMap().entries.map(
                        (e) => _buildMedicationTile(context, e.value, e.key + 1),
                  ),
                const SizedBox(height: 12),

                // 4. Notes
                if (prescription.notes != null || prescription.doctorNotes != null || prescription.patientNotes != null) ...[
                  _buildSectionLabel(context, 'ADDITIONAL NOTES'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (prescription.doctorNotes?.isNotEmpty == true)
                          _buildNoteItem(context, 'Doctor Note', prescription.doctorNotes!),
                        if (prescription.patientNotes?.isNotEmpty == true)
                          _buildNoteItem(context, 'My Note', prescription.patientNotes!),
                        if (prescription.notes?.isNotEmpty == true)
                          _buildNoteItem(context, 'General', prescription.notes!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 5. Safety Flags
                if (prescription.safetyFlags != null)
                  _buildSafetyFlags(context, prescription.safetyFlags!),

                // 6. Attachments
                if (prescription.uploadInfo?.hasFile == true) ...[
                  const SizedBox(height: 24),
                  _buildSectionLabel(context, 'ATTACHMENTS'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.tint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.accent.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.document_text5, color: t.accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prescription.uploadInfo?.fileName ?? 'Attached File',
                            style: TextStyle(color: t.accent, fontWeight: FontWeight.w700, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Sticky Bottom Actions
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CSSecondaryButton(
                    label: 'Download PDF',
                    onPressed: prescription.pdfUrl != null
                        ? () => _launchPdf(context, prescription.pdfUrl!)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CSPrimaryButton(
                    label: 'Share Copy',
                    onPressed: () {/* Share Copy */},
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final t = context.tokens;
    return BoxDecoration(
      color: t.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: t.divider),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: t.monoSectionHeader.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: t.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {String? subtitle, required IconData icon, bool isBold = false}) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: t.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                  color: t.textPrimary,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle, style: TextStyle(fontSize: 12, color: t.textSecondary, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaItem(BuildContext context, String label, String value, {bool isAlert = false}) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: t.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isAlert ? t.error : t.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationTile(BuildContext context, PrescriptionItem item, int index) {
    final t = context.tokens;
    final typeAndRoute = [
      if (item.displayMedicineType != null) item.displayMedicineType!,
      if (item.displayRoute != null) item.displayRoute!,
    ].join(' • ');

    final subtitleParts = [
      item.dosage,
      if (typeAndRoute.isNotEmpty) typeAndRoute,
      item.frequency,
      if (item.foodTiming != null && item.foodTiming!.trim().isNotEmpty) item.foodTiming!.trim(),
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: t.tint, shape: BoxShape.circle),
            child: Text('$index', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.accent)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.medicineName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  subtitleParts,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.displayInstructions != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: t.scaffold,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: t.divider),
                      ),
                      child: Text(
                        item.displayInstructions!,
                        style: TextStyle(fontSize: 11, color: t.textSecondary, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 12),
          if ((item.duration != null && item.duration!.trim().isNotEmpty) || (item.quantity != null && item.quantity! > 0))
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.duration != null && item.duration!.trim().isNotEmpty)
                  Text(
                    item.duration!.toLowerCase().contains('day')
                        ? item.duration!.trim()
                        : '${item.duration!.trim()} days',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.accent),
                  ),
                if (item.quantity != null && item.quantity! > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.scaffold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'QTY: ${item.quantity}',
                      style: t.monoMeta.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: t.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, String label, String content) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: t.textPrimary, fontWeight: FontWeight.w500, height: 1.4),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: content, style: TextStyle(color: t.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFlags(BuildContext context, SafetyFlags flags) {
    final t = context.tokens;
    if (flags.allergiesMentioned != true && flags.pregnancyBreastfeeding != true && flags.chronicConditionLinked != true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(context, 'SAFETY ALERTS'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              if (flags.allergiesMentioned == true) _buildSafetyRow(context, 'Allergies Detected'),
              if (flags.pregnancyBreastfeeding == true) _buildSafetyRow(context, 'Pregnancy/Breastfeeding Warning'),
              if (flags.chronicConditionLinked == true) _buildSafetyRow(context, 'Chronic Condition Linked'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyRow(BuildContext context, String text) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Iconsax.warning_2, size: 14, color: t.error),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.error),
          ),
        ],
      ),
    );
  }
}
