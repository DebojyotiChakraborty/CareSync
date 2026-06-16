// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VitalImpl _$$VitalImplFromJson(Map<String, dynamic> json) => _$VitalImpl(
  id: json['id'] as String,
  patientId: json['patient_id'] as String,
  type: json['type'] as String,
  value: json['value'] as String,
  unit: json['unit'] as String,
  recordedAt: DateTime.parse(json['recorded_at'] as String),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$VitalImplToJson(_$VitalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'type': instance.type,
      'value': instance.value,
      'unit': instance.unit,
      'recorded_at': instance.recordedAt.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };
