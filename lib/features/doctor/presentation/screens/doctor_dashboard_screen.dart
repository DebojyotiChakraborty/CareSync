import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/supabase_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../patient/providers/appointment_provider.dart';
import '../../../shared/models/appointment.dart';

// Provider for today's count
final doctorTodayStatsProvider = FutureProvider<int>((ref) async {
  return await SupabaseService.instance.getTodaysPrescriptionCount();
});

// Provider for total count
final doctorTotalStatsProvider = FutureProvider<int>((ref) async {
  return await SupabaseService.instance.getTotalPrescriptionCount();
});

// Provider for recent activity (last 3 days)
final recentActivityProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await SupabaseService.instance.getDoctorRecentPrescriptions();
});

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  bool _isOnDuty = true;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final profile = ref.watch(currentProfileProvider);
    final todayStats = ref.watch(doctorTodayStatsProvider);
    final totalStats = ref.watch(doctorTotalStatsProvider);
    final recentActivity = ref.watch(recentActivityProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);

    final todayDate = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());
    final displayName = profile.valueOrNull?.fullName ?? 'Physician';

    return Scaffold(
      backgroundColor: t.scaffold,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(doctorTodayStatsProvider);
          ref.invalidate(doctorTotalStatsProvider);
          ref.invalidate(recentActivityProvider);
          ref.invalidate(appointmentsProvider);
        },
        color: t.accent,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. HERO HEADER ───────────────────────────────────────────
              Container(
                width: double.infinity,
                color: t.card,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => context.push(RouteNames.profile),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: t.tint,
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'D',
                              style: TextStyle(
                                color: t.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Good Morning,',
                                    style: TextStyle(
                                      color: t.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _isOnDuty = !_isOnDuty),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: t.card,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isOnDuty
                                              ? t.accent
                                              : t.textSecondary,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _isOnDuty
                                                  ? t.accent
                                                  : t.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _isOnDuty ? 'On Duty' : 'Away',
                                            style: TextStyle(
                                              color: _isOnDuty
                                                  ? t.accent
                                                  : t.textSecondary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayName.startsWith('Dr.')
                                    ? displayName
                                    : 'Dr. $displayName',
                                style: TextStyle(
                                  color: t.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Text(
                                'Cardiology Department • St. Mary\'s',
                                style: TextStyle(
                                  color: t.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildHeaderIcon(Iconsax.notification,
                            () => context.push(RouteNames.notifications)),
                      ],
                    ),
                  ),
                ),
              ),

              // ── MAIN CONTENT BODY ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 2. METRICS GRID (2X2) ──────────────────────────────
                    GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.65,
                      children: [
                        _buildMetricCard(
                          title: 'Today\'s Rx',
                          value: todayStats.valueOrNull?.toString() ?? '0',
                          icon: Iconsax.document_text,
                          trend: 'Refreshed just now',
                        ),
                        _buildMetricCard(
                          title: 'Total Patients',
                          value: totalStats.valueOrNull?.toString() ?? '0',
                          icon: Iconsax.people,
                          trend: 'All-time active',
                        ),
                        _buildMetricCard(
                          title: 'In Clinic',
                          value: '3',
                          icon: Iconsax.location,
                          trend: 'Awaiting consult',
                        ),
                        _buildMetricCard(
                          title: 'Pending Reports',
                          value: '2',
                          icon: Iconsax.receipt_2,
                          trend: 'Requires review',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── 3. QUICK ACTIONS GRID (2X2) ────────────────────────
                    _sectionLabel('Quick Actions'),
                    const SizedBox(height: 8),
                    GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.1,
                      children: [
                        _buildActionCard(
                          title: 'New Rx',
                          subtitle: 'Issue Prescription',
                          icon: Iconsax.add_circle,
                          onTap: () =>
                              context.push(RouteNames.doctorPatientLookup),
                        ),
                        _buildActionCard(
                          title: 'Find Patient',
                          subtitle: 'Lookup Records',
                          icon: Iconsax.personalcard,
                          onTap: () =>
                              context.push(RouteNames.doctorPatientLookup),
                        ),
                        _buildActionCard(
                          title: 'Availability',
                          subtitle: 'Clinic Timeslots',
                          icon: Iconsax.calendar_1,
                          onTap: () => context.push('/doctor/availability'),
                        ),
                        _buildActionCard(
                          title: 'History Logs',
                          subtitle: 'Signed Records',
                          icon: Iconsax.clock,
                          onTap: () => context.push(RouteNames.doctorHistory),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── 4. TODAY'S SCHEDULE ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionLabel('Today\'s Schedule'),
                        Text(
                          todayDate,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    appointmentsAsync.when(
                      loading: () => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: t.accent),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Text(
                          'Error loading schedule: $err',
                          style:
                              TextStyle(color: t.textSecondary, fontSize: 13),
                        ),
                      ),
                      data: (list) {
                        final now = DateTime.now();
                        final todayAppointments = list.where((app) {
                          final appDate = app.startTime;
                          return appDate.year == now.year &&
                              appDate.month == now.month &&
                              appDate.day == now.day;
                        }).toList();

                        return _buildScheduleContainer(todayAppointments);
                      },
                    ),
                    const SizedBox(height: 18),

                    // ── 5. RECENT ACTIVITY ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionLabel('Recent Patients'),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.doctorHistory),
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
                    const SizedBox(height: 8),
                    recentActivity.when(
                      loading: () => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: t.accent),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Text(
                          'Error loading activity: $err',
                          style:
                              TextStyle(color: t.textSecondary, fontSize: 13),
                        ),
                      ),
                      data: (data) {
                        if (data.isEmpty) {
                          return _buildEmptyActivity();
                        }
                        return Column(
                          children: data.take(3).map((rx) {
                            final patient =
                                rx['patient'] as Map<String, dynamic>?;
                            final profiles =
                                patient?['profiles'] as Map<String, dynamic>?;
                            final patientName =
                                profiles?['full_name'] as String? ??
                                    'Unknown Patient';
                            final diagnosis =
                                rx['diagnosis'] as String? ?? 'No diagnosis';
                            final date = DateTime.parse(rx['created_at']);
                            final formattedDate =
                                DateFormat('MMM d, h:mm a').format(date);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SquircleCard(
                                radius: AppSpacing.squircleGrouped,
                                padding: EdgeInsets.zero,
                                onTap: () {
                                  context.push(
                                    RouteNames.doctorPatientRecord,
                                    extra: {
                                      'patientId':
                                          patient?['id'] as String? ?? '',
                                      'patientName': patientName,
                                    },
                                  );
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 2),
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: t.tint,
                                    child: Text(
                                      patientName.isNotEmpty
                                          ? patientName[0].toUpperCase()
                                          : 'P',
                                      style: TextStyle(
                                        color: t.accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    patientName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: t.textPrimary),
                                  ),
                                  subtitle: Text(
                                    '$diagnosis • $formattedDate',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: t.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: t.textSecondary,
                                    size: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: t.card,
            shape: BoxShape.circle,
            border: Border.all(color: t.divider),
          ),
          child: Icon(icon, color: t.textPrimary, size: 18),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    final t = context.tokens;
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: t.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required String trend,
  }) {
    final t = context.tokens;
    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: t.monoMeta.copyWith(
                  color: t.textSecondary,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: t.textSecondary, size: 14),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trend,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final t = context.tokens;
    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: t.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: t.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySchedule() {
    final t = context.tokens;
    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Icon(Iconsax.calendar_1, size: 28, color: t.textSecondary),
          const SizedBox(height: 8),
          Text(
            'No appointments today',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your calendar is clear. Enjoy your day!',
            style: TextStyle(fontSize: 10.5, color: t.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContainer(List<Appointment> appointments) {
    final t = context.tokens;
    if (appointments.isEmpty) {
      return _buildEmptySchedule();
    }

    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: appointments.map((app) {
          final isCompleted = app.status == 'completed';
          final isCancelled = app.status == 'cancelled';

          Color statusColor;
          String statusText;
          if (isCompleted) {
            statusColor = t.textSecondary;
            statusText = 'Completed';
          } else if (isCancelled) {
            statusColor = t.error;
            statusText = 'Cancelled';
          } else {
            statusColor = t.accent;
            statusText = 'Scheduled';
          }

          final timeFormatted = DateFormat('hh:mm a').format(app.startTime);
          final patientName = app.patient?.fullName ?? 'Unknown Patient';
          final reason = app.notes != null && app.notes!.isNotEmpty
              ? app.notes!
              : 'Consultation';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    timeFormatted,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: t.textSecondary,
                    ),
                  ),
                ),
                Container(
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary,
                        ),
                      ),
                      Text(
                        reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: t.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border.all(color: statusColor, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: t.monoMeta.copyWith(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyActivity() {
    final t = context.tokens;
    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            'No recent patient activity',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Issued patient records will appear in your clinical list.',
            style: TextStyle(fontSize: 10.5, color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
