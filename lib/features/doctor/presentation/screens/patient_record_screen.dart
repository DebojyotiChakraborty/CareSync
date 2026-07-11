import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'dart:math';
import '../../../../core/design/linear_fade_appbar.dart';
import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/encryption_service.dart';
import '../../../patient/models/patient_data.dart';
import '../../../patient/models/vital.dart';
import '../../providers/doctor_patient_provider.dart';

class PatientRecordScreen extends ConsumerWidget {
  final String patientId;
  final String patientName;

  const PatientRecordScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  Future<List<Vital>> _decryptVitals(List<Vital> encrypted) async {
    final list = <Vital>[];
    for (var v in encrypted) {
      try {
        final val = await EncryptionService.instance.decryptMedicalRecord(
          encryptedData: v.value,
          patientId: patientId,
        );
        list.add(v.copyWith(value: val));
      } catch (e) {
        list.add(v.copyWith(value: 'Error'));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final patientData = ref.watch(doctorPatientDataProvider(patientId));
    final vitals = ref.watch(doctorPatientVitalsProvider(patientId));
    final conditions = ref.watch(doctorPatientConditionsProvider(patientId));
    final prescriptions =
        ref.watch(doctorPatientPrescriptionsProvider(patientId));

    return CSScaffold(
      title: patientName,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RouteNames.doctorNewPrescription, extra: {
            'patientId': patientId,
            'patientName': patientName,
          });
        },
        backgroundColor: t.accent,
        foregroundColor: t.accentOn,
        elevation: 0,
        icon: const Icon(Iconsax.add, size: 18),
        label: const Text(
          'Issue Prescription',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: -0.2,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── 1. PATIENT HEADER DETAIL ─────────────────────────────────
            patientData.when(
              data: (data) => _buildHeaderCard(context, data),
              loading: () =>
                  LinearProgressIndicator(color: t.accent, minHeight: 2),
              error: (_, __) => const SizedBox.shrink(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 2. RECENT VITALS ───────────────────────────────────
                  _buildSectionLabel(context, 'Recent Vitals'),
                  const SizedBox(height: 12),
                  vitals.when(
                    data: (v) => FutureBuilder<List<Vital>>(
                      future: _decryptVitals(v),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: t.accent),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error decrypting vitals: ${snapshot.error}'));
                        }
                        final decryptedVitals = snapshot.data ?? [];
                        return _buildVitalsChartOrGrid(context, decryptedVitals);
                      },
                    ),
                    loading: () => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: t.accent),
                      ),
                    ),
                    error: (e, __) =>
                        Center(child: Text('Error loading vitals: $e')),
                  ),

                  const SizedBox(height: 28),

                  // ── 3. MEDICAL CONDITIONS ──────────────────────────────
                  _buildSectionLabel(context, 'Medical Conditions'),
                  const SizedBox(height: 12),
                  conditions.when(
                    data: (c) => _buildConditionsList(context, c),
                    loading: () => const SizedBox.shrink(),
                    error: (e, __) =>
                        Center(child: Text('Error loading conditions: $e')),
                  ),

                  const SizedBox(height: 28),

                  // ── 4. PRESCRIPTION HISTORY ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel(context, 'Prescription History'),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            RouteNames.doctorHistory,
                            extra: {
                              'patientId': patientId,
                              'patientName': patientName,
                            },
                          );
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: t.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  prescriptions.when(
                    data: (p) => _buildPrescriptionList(context, p),
                    loading: () => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: t.accent),
                      ),
                    ),
                    error: (e, __) =>
                        Center(child: Text('Error loading prescriptions: $e')),
                  ),
                  const SizedBox(height: 120), // Padding to clear FAB
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, PatientData? patient) {
    final t = context.tokens;
    if (patient == null) return const SizedBox.shrink();

    final name = patient.fullName ?? patientName;
    final patientInitials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
    final ageStr = _calculateAge(patient.dateOfBirth);
    final genderStr = patient.gender != null
        ? (patient.gender!.substring(0, 1).toUpperCase() +
            patient.gender!.substring(1).toLowerCase())
        : 'N/A';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: t.card,
        border: Border(bottom: BorderSide(color: t.divider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Patient Info Top Bar ───────────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.tint,
                  border: Border.all(color: t.accent.withValues(alpha: 0.15), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  patientInitials.substring(
                      0, min(2, patientInitials.length)),
                  style: TextStyle(
                    color: t.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'RECORD ID • ${patient.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        color: t.textSecondary.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: t.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 18),

          // ── Demographics Grid ──────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _buildInfoGridItem(context, 'Age', ageStr)),
              Expanded(child: _buildInfoGridItem(context, 'Gender', genderStr)),
              Expanded(child: _buildInfoGridItem(context, 'Blood Type', patient.bloodType ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoGridItem(context, 'Weight', patient.weight != null ? "${patient.weight!.toStringAsFixed(0)} kg" : 'N/A')),
              Expanded(child: _buildInfoGridItem(context, 'Height', patient.height != null ? "${patient.height!.toStringAsFixed(0)} cm" : 'N/A')),
              Expanded(child: _buildInfoGridItem(context, 'DOB', patient.dateOfBirth != null ? DateFormat('dd MMM yyyy').format(patient.dateOfBirth!) : 'N/A')),
            ],
          ),

          // ── Emergency Contact ──────────────────────────────────────────
          if (patient.emergencyContact != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, color: t.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Contact',
                          style: t.monoMeta.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: t.error,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.emergencyContact!.name} (${patient.emergencyContact!.relationship ?? "Contact"})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: t.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          patient.emergencyContact!.phone,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoGridItem(BuildContext context, String label, String value) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: t.textSecondary.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsChartOrGrid(BuildContext context, List<Vital> vitals) {
    final t = context.tokens;
    if (vitals.isEmpty) return _buildEmptyCard(context, 'No vitals recorded');

    // Group vitals by type
    final grouped = <String, List<Vital>>{};
    for (var v in vitals) {
      grouped.putIfAbsent(v.type, () => []).add(v);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: grouped.entries.map((entry) {
            final type = entry.key;
            final list = entry.value.reversed.toList();
            final latest = entry.value.first;

            // Parse values
            final values = <double>[];
            final secondaryValues = <double>[];

            for (var v in list) {
              if (type == 'blood_pressure') {
                final parts = v.value.split('/');
                final sys = double.tryParse(parts[0]) ?? 120.0;
                final dia =
                    parts.length > 1 ? (double.tryParse(parts[1]) ?? 80.0) : 80.0;
                values.add(sys);
                secondaryValues.add(dia);
              } else {
                final val = double.tryParse(v.value) ?? 0.0;
                values.add(val);
              }
            }

            final chartColor = t.accent;
            final title = type.replaceAll('_', ' ').toUpperCase();

<<<<<<< Updated upstream
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SquircleCard(
            radius: AppSpacing.squircleGrouped,
            borderSide: BorderSide(color: t.divider),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
=======
            return SizedBox(
              width: itemWidth,
              height: 112,
              child: SquircleCard(
                radius: AppSpacing.squircleGrouped,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
>>>>>>> Stashed changes
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: t.textSecondary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      latest.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: t.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    latest.unit,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: t.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: t.tint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${list.length} Log${list.length > 1 ? "s" : ""}',
                            style: TextStyle(
                              fontSize: 9,
                              color: t.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (list.length > 1)
                      SizedBox(
                        height: 36,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _VitalsChartPainter(
                            values: values,
                            secondaryValues:
                                type == 'blood_pressure' ? secondaryValues : null,
                            color: chartColor,
                            secondaryColor: type == 'blood_pressure'
                                ? chartColor.withValues(alpha: 0.45)
                                : null,
                            ringColor: t.card,
                          ),
                        ),
                      )
                    else ...[
                      const Spacer(),
                      Text(
                        'Recorded:\n${DateFormat('dd MMM yyyy, h:mm a').format(latest.createdAt ?? DateTime.now())}',
                        style: TextStyle(
                          fontSize: 10,
                          color: t.textSecondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildConditionsList(BuildContext context, List<dynamic> conditions) {
    final t = context.tokens;
    if (conditions.isEmpty) {
      return _buildEmptyCard(context, 'No conditions listed');
    }
    return Column(
      children: conditions.map((c) {
        final isAllergy = c.conditionType == 'allergy';
        // Allergies flag risk (error); everything else uses the accent.
        final displayColor = isAllergy ? t.error : t.accent;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SquircleCard(
            radius: AppSpacing.squircleGrouped,
            borderSide: BorderSide(color: t.divider),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: displayColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.description,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: t.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${c.conditionTypeDisplayName}${c.severity != null ? " • Severity: ${c.severity}" : ""}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrescriptionList(
      BuildContext context, List<dynamic> prescriptions) {
    final t = context.tokens;
    if (prescriptions.isEmpty) {
      return _buildEmptyCard(context, 'No history found');
    }
    return Column(
      children: prescriptions.take(3).map((p) {
        final dateStr = DateFormat('MMM dd, yyyy').format(p.createdAt!);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SquircleCard(
            radius: AppSpacing.squircleGrouped,
            borderSide: BorderSide(color: t.divider),
            padding: EdgeInsets.zero,
            onTap: () {},
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                p.diagnosis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: t.textPrimary,
                ),
              ),
              subtitle: Text(
                dateStr,
                style: TextStyle(
                  color: t.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(Iconsax.clock, color: t.textSecondary, size: 16),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    final t = context.tokens;
    return Text(
      text.toUpperCase(),
      style: t.monoSectionHeader.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: t.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: t.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _calculateAge(DateTime? dob) {
    if (dob == null) return 'N/A';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age.toString();
  }
}

class _VitalsChartPainter extends CustomPainter {
  final List<double> values;
  final List<double>? secondaryValues; // For diastolic BP
  final Color color;
  final Color? secondaryColor;
  final Color ringColor;

  _VitalsChartPainter({
    required this.values,
    this.secondaryValues,
    required this.color,
    this.secondaryColor,
    required this.ringColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Find min and max for scaling
    double minVal = values.reduce(min);
    double maxVal = values.reduce(max);
    if (secondaryValues != null && secondaryValues!.isNotEmpty) {
      final minSec = secondaryValues!.reduce(min);
      final maxSec = secondaryValues!.reduce(max);
      minVal = min(minVal, minSec);
      maxVal = max(maxVal, maxSec);
    }

    // Add padding to min/max
    final range = maxVal - minVal;
    minVal = minVal - (range * 0.15);
    maxVal = maxVal + (range * 0.15);
    if (maxVal == minVal) {
      minVal -= 10;
      maxVal += 10;
    }

    final double width = size.width;
    final double height = size.height;

    // Draw main line
    final points = <Offset>[];
    if (values.length == 1) {
      points.add(Offset(0, height / 2));
      points.add(Offset(width, height / 2));
    } else {
      for (int i = 0; i < values.length; i++) {
        final x = (i / (values.length - 1)) * width;
        final y = height - ((values[i] - minVal) / (maxVal - minVal)) * height;
        points.add(Offset(x, y));
      }
    }

    _drawSmoothLine(canvas, points, paint, size, color);

    // Draw secondary line if provided
    if (secondaryValues != null && secondaryValues!.length == values.length) {
      final secPaint = Paint()
        ..color = secondaryColor ?? color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      final secPoints = <Offset>[];
      if (secondaryValues!.length == 1) {
        secPoints.add(Offset(0, height / 2));
        secPoints.add(Offset(width, height / 2));
      } else {
        for (int i = 0; i < secondaryValues!.length; i++) {
          final x = (i / (secondaryValues!.length - 1)) * width;
          final y = height -
              ((secondaryValues![i] - minVal) / (maxVal - minVal)) * height;
          secPoints.add(Offset(x, y));
        }
      }

      _drawSmoothLine(canvas, secPoints, secPaint, size,
          secondaryColor ?? color.withValues(alpha: 0.5),
          fill: false);
    }
  }

  void _drawSmoothLine(
      Canvas canvas, List<Offset> points, Paint paint, Size size, Color lineColor,
      {bool fill = true}) {
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    if (points.length == 1) {
      canvas.drawCircle(points[0], 3.0, paint..style = PaintingStyle.fill);
      return;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
          controlPoint2.dy, p1.dx, p1.dy);
    }

    canvas.drawPath(path, paint);

    // Fill area under the curve
    if (fill && points.length > 1) {
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.15),
            lineColor.withValues(alpha: 0.00),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw a small dot on the last point
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.last, 3.5, dotPaint);

    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(points.last, 3.5, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _VitalsChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.secondaryValues != secondaryValues;
  }
}
