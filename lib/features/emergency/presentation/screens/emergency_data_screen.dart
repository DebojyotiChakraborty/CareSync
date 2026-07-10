import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../../../core/design/cs_buttons.dart';
import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../services/supabase_service.dart';

final emergencyDataProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, qrCodeId) async {
  return await SupabaseService.instance.getEmergencyData(qrCodeId);
});

class EmergencyDataScreen extends ConsumerStatefulWidget {
  final String qrCodeId;
  const EmergencyDataScreen({super.key, required this.qrCodeId});

  @override
  ConsumerState<EmergencyDataScreen> createState() => _EmergencyDataScreenState();
}

class _EmergencyDataScreenState extends ConsumerState<EmergencyDataScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  int? _calculateAge(String? dobStr) {
    if (dobStr == null) return null;
    final dob = DateTime.tryParse(dobStr);
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final emergencyData = ref.watch(emergencyDataProvider(widget.qrCodeId));
    final t = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: t.scaffold,
        body: emergencyData.when(
          data: (data) {
            if (data == null) return _buildNotFound(context);
            return _buildEmergencyDashboard(context, data);
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: t.error),
          ),
          error: (e, _) => _buildError(context),
        ),
      ),
    );
  }

  Widget _buildEmergencyDashboard(BuildContext context, Map<String, dynamic> data) {
    final t = context.tokens;
    final patient = data['patient'] as Map<String, dynamic>?;
    final rawConditions = data['conditions'] as List? ?? [];
    final medications = data['medications'] as List? ?? [];

    final conditionsList = List<Map<String, dynamic>>.from(rawConditions);

    final criticalAlerts = conditionsList.where((c) {
      final severity = c['severity']?.toString().toLowerCase() ?? '';
      return severity == 'critical' || severity == 'high';
    }).toList();

    final allergies = conditionsList.where((c) {
      final type = c['type']?.toString().toLowerCase() ?? '';
      return type == 'allergy';
    }).toList();

    final chronicConditions = conditionsList.where((c) {
      final type = c['type']?.toString().toLowerCase() ?? '';
      return type != 'allergy';
    }).toList();

    final age = _calculateAge(patient?['date_of_birth']?.toString());
    final bloodType = patient?['blood_type']?.toString() ?? 'UNK';
    final gender = patient?['gender']?.toString() ?? '';
    final avatarUrl = patient?['avatar_url']?.toString();
    final medicalId = (patient?['id']?.toString() ?? '').substring(0, 8).toUpperCase();

    String bloodGroup = bloodType;
    String rhFactor = '';
    if (bloodType.endsWith('+')) {
      bloodGroup = bloodType.substring(0, bloodType.length - 1);
      rhFactor = '+';
    } else if (bloodType.endsWith('-')) {
      bloodGroup = bloodType.substring(0, bloodType.length - 1);
      rhFactor = '−';
    }

    final contact = patient?['emergency_contact'] as Map<String, dynamic>?;
    final primaryPhone = contact?['phone']?.toString();
    final vitals = (data['vitals'] as Map<String, dynamic>?) ?? {};
    final physician = data['physician'] as Map<String, dynamic>?;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeaderSection(
            fullName: patient?['full_name'] ?? 'Unidentified Patient',
            age: age,
            gender: gender,
            bloodGroup: bloodGroup,
            rhFactor: rhFactor,
            medicalId: medicalId,
            avatarUrl: avatarUrl,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: t.scaffold,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (criticalAlerts.isNotEmpty) ...[
                      _buildCriticalAlertsSection(criticalAlerts),
                      const SizedBox(height: 16),
                    ],
                    _buildAllergiesSection(allergies),
                    const SizedBox(height: 16),
                    _buildMedicationsSection(medications),
                    const SizedBox(height: 16),
                    _buildChronicConditionsSection(chronicConditions),
                    const SizedBox(height: 16),
                    _buildVitalsSection(vitals),
                    const SizedBox(height: 16),
                    _buildPhysicalSection(patient),
                    const SizedBox(height: 16),
                    _buildPhysicianSection(physician),
                    const SizedBox(height: 16),
                    _buildContactsSection(patient),
                    const SizedBox(height: 16),
                    _buildQRBackupSection(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          _buildQuickActionBar(primaryPhone),
        ],
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeaderSection({
    required String fullName,
    required int? age,
    required String gender,
    required String bloodGroup,
    required String rhFactor,
    required String medicalId,
    String? avatarUrl,
  }) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(color: t.card),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: t.textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded,
                        color: t.textPrimary, size: 22),
                    onPressed: () {
                      ref.invalidate(emergencyDataProvider(widget.qrCodeId));
                    },
                    tooltip: 'Refresh clinical data',
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          t.error.withValues(alpha: 0.15),
                          t.error.withValues(alpha: 0.35),
                          _pulseAnimation.value,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: t.error.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: t.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EMERGENCY ACCESS',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: t.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Patient identity row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: t.error, width: 2.0),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: t.tint,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(
                              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: t.textPrimary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: t.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (gender.isNotEmpty)
                              _headerChip(gender.toUpperCase(), t.accent),
                            if (gender.isNotEmpty) const SizedBox(width: 6),
                            if (age != null)
                              _headerChip('$age YRS', t.accent),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ID: $medicalId',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            color: t.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Blood type badge
                  if (bloodGroup != 'UNK') ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: t.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            bloodGroup,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: t.accentOn,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            rhFactor,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: t.accentOn.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Sans',
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ─── CRITICAL ALERTS ───────────────────────────────────────────────────────

  Widget _buildCriticalAlertsSection(List<Map<String, dynamic>> alerts) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('CRITICAL ALERTS', Iconsax.warning_2, t.error),
        const SizedBox(height: 10),
        ...alerts.map((alert) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  left: BorderSide(color: t.error, width: 4),
                  top: BorderSide(color: t.error.withValues(alpha: 0.2), width: 1),
                  right: BorderSide(color: t.error.withValues(alpha: 0.2), width: 1),
                  bottom: BorderSide(color: t.error.withValues(alpha: 0.2), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, color: t.error, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      alert['description']?.toString() ?? 'Critical Alert',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: t.error,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: t.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (alert['severity']?.toString() ?? 'HIGH').toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: t.accentOn,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ─── ALLERGIES ─────────────────────────────────────────────────────────────

  Widget _buildAllergiesSection(List<Map<String, dynamic>> allergies) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ALLERGIES', Iconsax.mask_1, t.accent),
        const SizedBox(height: 10),
        if (allergies.isEmpty)
          _buildEmptyCard('No recorded allergies.', Iconsax.tick_circle)
        else
          _buildCard(
            child: Column(
              children: List.generate(allergies.length, (i) {
                final allergy = allergies[i];
                final severity = allergy['severity']?.toString() ?? '';
                final isSevere = severity.toLowerCase() == 'severe' ||
                    severity.toLowerCase() == 'critical';
                return Column(
                  children: [
                    if (i > 0) Divider(height: 1, color: t.divider),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSevere
                                  ? t.error.withValues(alpha: 0.08)
                                  : t.tint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Iconsax.warning_2,
                              size: 18,
                              color: isSevere ? t.error : t.accent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              allergy['description']?.toString() ?? 'Unknown Allergy',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: t.textPrimary,
                              ),
                            ),
                          ),
                          if (severity.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSevere
                                    ? t.error.withValues(alpha: 0.08)
                                    : t.tint,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSevere
                                      ? t.error.withValues(alpha: 0.3)
                                      : t.accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                severity.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  color: isSevere ? t.error : t.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }

  // ─── MEDICATIONS ───────────────────────────────────────────────────────────

  Widget _buildMedicationsSection(List medications) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'ACTIVE MEDICATIONS', Icons.medication_rounded, t.accent),
        const SizedBox(height: 10),
        if (medications.isEmpty)
          _buildEmptyCard('No active medications on record.', Iconsax.document)
        else
          ...medications.map((med) {
            final name = med['medicine']?.toString() ?? 'Unknown';
            final dosage = med['dosage']?.toString();
            final frequency = med['frequency']?.toString();
            return SquircleCard(
              radius: AppSpacing.squircleGrouped,
              color: t.card,
              borderSide: BorderSide(color: t.divider),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.medication_rounded,
                        color: t.accent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: t.textPrimary,
                          ),
                        ),
                        if (dosage != null || frequency != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            [
                              if (dosage != null) 'Dose: $dosage',
                              if (frequency != null) frequency,
                            ].join('  •  '),
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: t.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ─── CHRONIC CONDITIONS ────────────────────────────────────────────────────

  Widget _buildChronicConditionsSection(List<Map<String, dynamic>> chronic) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'MEDICAL CONDITIONS', Iconsax.activity, t.accent),
        const SizedBox(height: 10),
        if (chronic.isEmpty)
          _buildEmptyCard('No recorded chronic conditions.', Iconsax.activity)
        else
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chronic.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: t.tint,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: t.accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      (item['description'] ?? 'Condition').toString(),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        color: t.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  // ─── PHYSICAL MEASUREMENTS ────────────────────────────────────────────────

  // ─── VITALS ───────────────────────────────────────────────────────────────

  Widget _buildVitalsSection(Map<String, dynamic> vitals) {
    final t = context.tokens;
    final vitalDefs = [
      {
        'key': 'blood_pressure',
        'label': 'BLOOD PRESSURE',
        'unit': 'mmHg',
        'icon': Icons.favorite_rounded,
        'color': t.accent,
      },
      {
        'key': 'heart_rate',
        'label': 'HEART RATE',
        'unit': 'bpm',
        'icon': Iconsax.heart,
        'color': t.accent,
      },
      {
        'key': 'glucose',
        'label': 'BLOOD GLUCOSE',
        'unit': 'mg/dL',
        'icon': Iconsax.drop,
        'color': t.accent,
      },
      {
        'key': 'weight',
        'label': 'WEIGHT',
        'unit': 'kg',
        'icon': Iconsax.weight,
        'color': t.accent,
      },
    ];

    final availableVitals = vitalDefs
        .where((def) => vitals.containsKey(def['key']))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('LATEST VITALS', Iconsax.health, t.accent),
        const SizedBox(height: 10),
        if (availableVitals.isEmpty)
          _buildEmptyCard('No vitals recorded yet.', Iconsax.health)
        else
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableVitals.map((def) {
                  final entry = vitals[def['key']] as Map<String, dynamic>?;
                  final value = entry?['value']?.toString() ?? '—';
                  final unit = entry?['unit']?.toString() ?? def['unit'] as String;
                  final recordedAt = entry?['recorded_at']?.toString();
                  final color = def['color'] as Color;
                  final icon = def['icon'] as IconData;
                  final label = def['label'] as String;

                  DateTime? parsedDate;
                  if (recordedAt != null) {
                    parsedDate = DateTime.tryParse(recordedAt)?.toLocal();
                  }
                  final dateStr = parsedDate != null
                      ? '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}'
                      : null;

                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 60) / 2,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(icon, color: color, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: t.textSecondary,
                                    letterSpacing: 0.4,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            value,
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: t.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                unit,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  color: t.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (dateStr != null) ...[
                                const Spacer(),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 9,
                                    color: t.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  // ─── ATTENDING PHYSICIAN ──────────────────────────────────────────────────

  Widget _buildPhysicianSection(Map<String, dynamic>? physician) {
    final t = context.tokens;
    if (physician == null) return const SizedBox.shrink();

    final name = physician['full_name']?.toString();
    if (name == null || name.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'ATTENDING PHYSICIAN', Iconsax.user_octagon, t.accent),
        const SizedBox(height: 10),
        _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Iconsax.user_octagon,
                      color: t.accent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. $name',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: t.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Most recent prescribing physician',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          color: t.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── PHYSICAL MEASUREMENTS ────────────────────────────────────────────────

  Widget _buildPhysicalSection(Map<String, dynamic>? patient) {
    final t = context.tokens;
    final weight = patient?['weight'] != null
        ? double.tryParse(patient!['weight'].toString())
        : null;
    final height = patient?['height'] != null
        ? double.tryParse(patient!['height'].toString())
        : null;

    double? bmi;
    if (weight != null && height != null && height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
    }

    final hasData = weight != null || height != null;

    if (!hasData) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PHYSICAL MEASUREMENTS', Iconsax.weight, t.accent),
        const SizedBox(height: 10),
        _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (height != null)
                  Expanded(
                    child: _buildPhysicalTile(
                      Iconsax.ruler,
                      'HEIGHT',
                      '${height.toStringAsFixed(0)} cm',
                      t.accent,
                    ),
                  ),
                if (height != null && weight != null)
                  Container(
                    width: 1,
                    height: 50,
                    color: t.divider,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                if (weight != null)
                  Expanded(
                    child: _buildPhysicalTile(
                      Iconsax.weight,
                      'WEIGHT',
                      '${weight.toStringAsFixed(1)} kg',
                      t.accent,
                    ),
                  ),
                if (bmi != null) ...[
                  Container(
                    width: 1,
                    height: 50,
                    color: t.divider,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: _buildPhysicalTile(
                      Iconsax.activity,
                      'BMI',
                      bmi.toStringAsFixed(1),
                      t.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalTile(IconData icon, String label, String value, Color color) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: t.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: t.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ─── EMERGENCY CONTACTS ───────────────────────────────────────────────────

  Widget _buildContactsSection(Map<String, dynamic>? patient) {
    final t = context.tokens;
    final contact = patient?['emergency_contact'] as Map<String, dynamic>?;

    if (contact == null) return const SizedBox.shrink();

    final contactName = contact['name']?.toString();
    final contactRelationship = contact['relationship']?.toString();
    final contactPhone = contact['phone']?.toString();

    if (contactName == null && contactPhone == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('EMERGENCY CONTACT', Iconsax.call, t.accent),
        const SizedBox(height: 10),
        _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Iconsax.user, color: t.accent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contactName != null)
                        Text(
                          contactName,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: t.textPrimary,
                          ),
                        ),
                      if (contactRelationship != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          contactRelationship.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            color: t.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (contactPhone != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          contactPhone,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            color: t.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (contactPhone != null)
                  GestureDetector(
                    onTap: () async {
                      await launchUrl(Uri.parse('tel:$contactPhone'));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Iconsax.call, color: t.accentOn, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── QR BACKUP ────────────────────────────────────────────────────────────

  Widget _buildQRBackupSection() {
    final t = context.tokens;
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_rounded,
                    color: t.textPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'PATIENT QR CODE',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: t.textPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Scan to identify this patient in any CareSync station',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: t.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: PrettyQrView.data(
                    data: widget.qrCodeId,
                    decoration: const PrettyQrDecoration(
                      shape: PrettyQrSmoothSymbol(
                        roundFactor: 0.8,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: t.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  'END-TO-END ENCRYPTED • CARESYNC VERIFIED',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: t.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── QUICK ACTION BAR ─────────────────────────────────────────────────────

  Widget _buildQuickActionBar(String? primaryPhone) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.card,
        border: Border(top: BorderSide(color: t.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (primaryPhone != null)
              Expanded(
                child: _buildActionButton(
                  icon: Iconsax.call,
                  label: 'CALL NOK',
                  color: t.accent,
                  onTap: () async {
                    await launchUrl(Uri.parse('tel:$primaryPhone'));
                  },
                ),
              ),
            if (primaryPhone != null) const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.local_hospital_rounded,
                label: 'AMBULANCE',
                color: t.error,
                onTap: () async {
                  await launchUrl(Uri.parse('tel:112'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: t.accentOn, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                color: t.accentOn,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SHARED HELPERS ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon, Color accentColor) {
    final t = context.tokens;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accentColor, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'DM Sans',
            color: t.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    final t = context.tokens;
    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      color: t.card,
      borderSide: BorderSide(color: t.divider),
      padding: EdgeInsets.zero,
      child: child,
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    final t = context.tokens;
    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      color: t.card,
      borderSide: BorderSide(color: t.divider),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: t.textSecondary, size: 18),
          const SizedBox(width: 10),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'DM Sans',
              color: t.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.scaffold,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.close_circle,
                    size: 48, color: t.error),
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to Load Data',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: t.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'An error occurred loading this patient record. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  color: t.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              CSPrimaryButton(
                label: 'Go Back',
                onPressed: () => Navigator.pop(context),
                fullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.scaffold,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.textSecondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.search_status,
                    size: 48, color: t.textSecondary),
              ),
              const SizedBox(height: 20),
              Text(
                'Patient Not Found',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: t.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The scanned QR code does not match any registered CareSync patient.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  color: t.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              CSPrimaryButton(
                label: 'Back to Dashboard',
                onPressed: () => Navigator.pop(context),
                fullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
