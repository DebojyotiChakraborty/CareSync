import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/design/linear_fade_appbar.dart';
import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/supabase_service.dart';
import '../../../patient/providers/appointment_provider.dart';

class ManageAvailabilityScreen extends ConsumerStatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  ConsumerState<ManageAvailabilityScreen> createState() =>
      _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState
    extends ConsumerState<ManageAvailabilityScreen> {
  final Map<int, List<TimeOfDay>> _availability = {
    0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentAvailability();
  }

  Future<void> _loadCurrentAvailability() async {
    setState(() => _isLoading = true);
    final doctorId = SupabaseService.instance.currentUserId;
    if (doctorId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final current =
          await ref.read(doctorAvailabilityProvider(doctorId).future);
      if (current.isNotEmpty) {
        setState(() {
          for (var slot in current) {
            final timeParts = slot.startTime.split(':');
            final time = TimeOfDay(
                hour: int.parse(timeParts[0]),
                minute: int.parse(timeParts[1]));
            if (!_availability[slot.dayOfWeek]!.contains(time)) {
              _availability[slot.dayOfWeek]?.add(time);
            }
          }
          // Sort slots for each day
          for (var i = 0; i < 7; i++) {
            _availability[i]!.sort((a, b) => a.hour.compareTo(b.hour));
          }
        });
      }
    } catch (e) {
      debugPrint('[DOC] Error loading availability: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return CSScaffold(
      title: 'Manage Availability',
      actions: [
        TextButton(
          onPressed: _saveAvailability,
          child: Text(
            'SAVE',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: t.accent,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
      body: _isLoading
          ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: t.accent))
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayName = _getDayName(index);
                final slots = _availability[index]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SquircleCard(
                    radius: AppSpacing.squircleGrouped,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: t.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _addSlot(index),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: t.tint,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Iconsax.add, color: t.accent, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (slots.isEmpty)
                          Text(
                            'Unavailable',
                            style: TextStyle(
                              color: t.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: slots.map((slot) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: t.scaffold,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: t.divider),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      slot.format(context),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => slots.remove(slot)),
                                      child: Icon(
                                        Iconsax.close_circle,
                                        color: t.textSecondary,
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getDayName(int index) {
    return [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][index];
  }

  Future<void> _addSlot(int dayIndex) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        if (!_availability[dayIndex]!.contains(pickedTime)) {
          _availability[dayIndex]!.add(pickedTime);
          _availability[dayIndex]!.sort((a, b) => a.hour.compareTo(b.hour));
        }
      });
    }
  }

  Future<void> _saveAvailability() async {
    final doctorId = SupabaseService.instance.currentUserId;
    if (doctorId == null) return;

    setState(() => _isLoading = true);

    // Generate UPSERT data for Supabase
    final data = <Map<String, dynamic>>[];
    _availability.forEach((day, slots) {
      for (var slot in slots) {
        data.add({
          'day_of_week': day,
          'start_time':
              '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}:00',
          'end_time':
              '${(slot.hour + 1).toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}:00',
          'is_active': true,
        });
      }
    });

    try {
      // 1. Delete old slots to sync deletions
      await SupabaseService.instance.client
          .from('doctor_availability')
          .delete()
          .eq('doctor_id', doctorId);

      // 2. Insert new slots list
      if (data.isNotEmpty) {
        await ref.read(appointmentServiceProvider).setAvailability(data);
      }

      // 3. Sync riverpod cache
      ref.invalidate(doctorAvailabilityProvider(doctorId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Availability slots updated successfully!'),
            backgroundColor: context.tokens.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving availability: $e'),
            backgroundColor: context.tokens.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
