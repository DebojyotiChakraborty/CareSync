// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentImpl _$$AppointmentImplFromJson(Map<String, dynamic> json) =>
    _$AppointmentImpl(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      status: json['status'] as String? ?? 'scheduled',
      notes: json['notes'] as String?,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      patient:
          json['patient'] == null
              ? null
              : UserProfile.fromJson(json['patient'] as Map<String, dynamic>),
      doctor:
          json['doctor'] == null
              ? null
              : UserProfile.fromJson(json['doctor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AppointmentImplToJson(_$AppointmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'doctor_id': instance.doctorId,
      'start_time': instance.startTime.toIso8601String(),
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'patient': instance.patient,
      'doctor': instance.doctor,
    };

_$DoctorAvailabilityImpl _$$DoctorAvailabilityImplFromJson(
  Map<String, dynamic> json,
) => _$DoctorAvailabilityImpl(
  id: json['id'] as String,
  doctorId: json['doctor_id'] as String,
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$$DoctorAvailabilityImplToJson(
  _$DoctorAvailabilityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'doctor_id': instance.doctorId,
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'is_active': instance.isActive,
};
