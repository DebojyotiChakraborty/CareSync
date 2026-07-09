import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/vitals_provider.dart';
import '../../models/vital.dart';
import 'add_vital_bottom_sheet.dart';
import '../../../../services/encryption_service.dart';
import '../../../../core/widgets/loading_skeleton.dart';

class VitalsSummaryCard extends ConsumerWidget {
  const VitalsSummaryCard({super.key});

  void _showVitalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddVitalBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitalsAsync = ref.watch(patientVitalsProvider);
    return vitalsAsync.when(
      data: (vitalsList) {
        // 1. Heart Rate
        final hrLatest = _getLatest(vitalsList, 'heart_rate');
        final hrPrev = _getPrevious(vitalsList, 'heart_rate');
        final hrTrend = _calculateStatus(hrLatest, hrPrev, 'bpm');

        // 2. Blood Pressure
        final bpLatest = _getLatest(vitalsList, 'blood_pressure');
        final bpPrev = _getPrevious(vitalsList, 'blood_pressure');
        final bpTrend = _calculateStatus(bpLatest, bpPrev, 'mmHg');

        // 3. Weight
        final weightLatest = _getLatest(vitalsList, 'weight');
        final weightPrev = _getPrevious(vitalsList, 'weight');
        final weightTrend = _calculateWeightTrend(weightLatest, weightPrev);

        // Derive current display value from the latest manually-logged vital
        final String hrVal;
        if (hrLatest?.value != null) {
          String val = hrLatest!.value;
          try {
            val = EncryptionService.instance.decryptDeterministic(
              encryptedData: hrLatest.value,
              patientId: hrLatest.patientId,
            );
          } catch (_) {}
          hrVal = val;
        } else {
          hrVal = 'No data logged yet.';
        }
        final hrLabel =
            hrLatest != null ? (hrTrend['text'] as String) : 'No Data';
        final hrColor = hrLatest != null
            ? (hrTrend['color'] as Color)
            : AppColors.textSub;

        final String bpVal;
        if (bpLatest?.value != null) {
          String val = bpLatest!.value;
          try {
            val = EncryptionService.instance.decryptDeterministic(
              encryptedData: bpLatest.value,
              patientId: bpLatest.patientId,
            );
          } catch (_) {}
          bpVal = val;
        } else {
          bpVal = 'No data logged yet.';
        }
        final bpLabel =
            bpLatest != null ? (bpTrend['text'] as String) : 'No Data';
        final bpColor = bpLatest != null
            ? (bpTrend['color'] as Color)
            : AppColors.textSub;

        final String weightVal;
        if (weightLatest?.value != null) {
          String val = weightLatest!.value;
          try {
            val = EncryptionService.instance.decryptDeterministic(
              encryptedData: weightLatest.value,
              patientId: weightLatest.patientId,
            );
          } catch (_) {}
          weightVal = val;
        } else {
          weightVal = 'No data logged yet.';
        }
        final weightLabel = weightLatest != null
            ? (weightTrend['text'] as String)
            : 'No Data';
        final weightColor = weightLatest != null
            ? (weightTrend['color'] as Color)
            : AppColors.textSub;

        final bool showNoDataNotice = hrVal == 'No data logged yet.' ||
            bpVal == 'No data logged yet.' ||
            weightVal == 'No data logged yet.';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildVitalCard(
                  context,
                  iconWidget: const Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: Color(0xFFF472B6),
                  ),
                  value: hrVal,
                  unit: 'bpm',
                  label: 'Heart Rate',
                  trend: hrLabel,
                  trendColor: hrColor,
                  onTap: () => _showVitalOptions(context),
                ),
                const SizedBox(width: 12),
                _buildVitalCard(
                  context,
                  iconWidget: const Icon(
                    Icons.water_drop_rounded,
                    size: 14,
                    color: Color(0xFF60A5FA),
                  ),
                  value: bpVal,
                  unit: 'mmHg',
                  label: 'Blood Pressure',
                  trend: bpLabel,
                  trendColor: bpColor,
                  onTap: () => _showVitalOptions(context),
                ),
                const SizedBox(width: 12),
                _buildVitalCard(
                  context,
                  iconWidget: const Icon(
                    Icons.monitor_weight_outlined,
                    size: 14,
                    color: Color(0xFF34D399),
                  ),
                  value: weightVal,
                  unit: 'kg',
                  label: 'Weight',
                  trend: weightLabel,
                  trendColor: weightColor,
                  onTap: () => _showVitalOptions(context),
                ),
              ],
            ),
            if (showNoDataNotice) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap a card to log your vitals manually.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
      loading:
          () => Row(
            children: [
              Expanded(child: LoadingSkeleton(height: 100, radius: 20)),
              const SizedBox(width: 12),
              Expanded(child: LoadingSkeleton(height: 100, radius: 20)),
              const SizedBox(width: 12),
              Expanded(child: LoadingSkeleton(height: 100, radius: 20)),
            ],
          ),
      error: (err, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildVitalCard(
    BuildContext context, {
    required Widget iconWidget,
    required String value,
    required String unit,
    required String label,
    required String trend,
    required Color trendColor,
    required VoidCallback onTap,
  }) {
    final bool isNoData = value == 'No data logged yet.';
    final String displayValue = isNoData ? '--' : value;
    final String displayUnit = isNoData ? '' : unit;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Label
              Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Value and Unit Row
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayValue,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF121212),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (displayUnit.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Text(
                        displayUnit,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Minimal Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Vital? _getLatest(List<Vital> vitals, String type) {
    final filtered = vitals.where((v) => v.type == type).toList();
    if (filtered.isEmpty) return null;
    filtered.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return filtered.first;
  }

  Vital? _getPrevious(List<Vital> vitals, String type) {
    final filtered = vitals.where((v) => v.type == type).toList();
    if (filtered.length < 2) return null;
    filtered.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return filtered[1];
  }

  Map<String, dynamic> _calculateStatus(
    Vital? latest,
    Vital? prev,
    String unit,
  ) {
    if (latest == null)
      return {'text': 'No record', 'color': AppColors.textSub};

    final val = latest.value;
    if (unit == 'bpm') {
      try {
        final rate = int.parse(val);
        if (rate >= 60 && rate <= 100) {
          return {'text': 'Normal', 'color': AppColors.trendSuccess};
        } else {
          return {
            'text': rate < 60 ? 'Low' : 'High',
            'color': AppColors.trendWarning,
          };
        }
      } catch (_) {
        return {'text': 'Logged', 'color': AppColors.trendSuccess};
      }
    }

    if (unit == 'mmHg') {
      try {
        final parts = val.split('/');
        final sys = int.parse(parts[0]);
        final dia = int.parse(parts[1]);
        if (sys < 120 && dia < 80) {
          return {'text': 'Optimal', 'color': AppColors.trendSuccess};
        } else if (sys <= 129 && dia < 80) {
          return {'text': 'Normal', 'color': AppColors.trendSuccess};
        } else {
          return {'text': 'Elevated', 'color': AppColors.trendWarning};
        }
      } catch (_) {
        return {'text': 'Logged', 'color': AppColors.trendSuccess};
      }
    }

    return {'text': 'Stable', 'color': AppColors.textSub};
  }

  Map<String, dynamic> _calculateWeightTrend(Vital? latest, Vital? prev) {
    if (latest == null)
      return {'text': 'No record', 'color': AppColors.textSub};
    if (prev == null) return {'text': 'Stable', 'color': AppColors.textSub};

    try {
      final curW = double.parse(latest.value);
      final preW = double.parse(prev.value);
      final diff = curW - preW;
      if (diff.abs() < 0.1) {
        return {'text': 'Stable', 'color': AppColors.textSub};
      }
      final direction = diff > 0 ? '+' : '';
      return {
        'text': '$direction${diff.toStringAsFixed(1)} kg',
        'color': diff > 0 ? AppColors.trendWarning : AppColors.trendSuccess,
      };
    } catch (_) {
      return {'text': 'Stable', 'color': AppColors.textSub};
    }
  }
}
