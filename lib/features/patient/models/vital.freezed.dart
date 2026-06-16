// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vital.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Vital _$VitalFromJson(Map<String, dynamic> json) {
  return _Vital.fromJson(json);
}

/// @nodoc
mixin _$Vital {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_id')
  String get patientId => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'blood_pressure', 'glucose', 'weight', 'heart_rate'
  String get value =>
      throw _privateConstructorUsedError; // Encrypted Base64 string
  String get unit => throw _privateConstructorUsedError;
  @JsonKey(name: 'recorded_at')
  DateTime get recordedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Vital to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vital
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VitalCopyWith<Vital> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VitalCopyWith<$Res> {
  factory $VitalCopyWith(Vital value, $Res Function(Vital) then) =
      _$VitalCopyWithImpl<$Res, Vital>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'patient_id') String patientId,
    String type,
    String value,
    String unit,
    @JsonKey(name: 'recorded_at') DateTime recordedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$VitalCopyWithImpl<$Res, $Val extends Vital>
    implements $VitalCopyWith<$Res> {
  _$VitalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vital
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? recordedAt = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            patientId:
                null == patientId
                    ? _value.patientId
                    : patientId // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            value:
                null == value
                    ? _value.value
                    : value // ignore: cast_nullable_to_non_nullable
                        as String,
            unit:
                null == unit
                    ? _value.unit
                    : unit // ignore: cast_nullable_to_non_nullable
                        as String,
            recordedAt:
                null == recordedAt
                    ? _value.recordedAt
                    : recordedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VitalImplCopyWith<$Res> implements $VitalCopyWith<$Res> {
  factory _$$VitalImplCopyWith(
    _$VitalImpl value,
    $Res Function(_$VitalImpl) then,
  ) = __$$VitalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'patient_id') String patientId,
    String type,
    String value,
    String unit,
    @JsonKey(name: 'recorded_at') DateTime recordedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$VitalImplCopyWithImpl<$Res>
    extends _$VitalCopyWithImpl<$Res, _$VitalImpl>
    implements _$$VitalImplCopyWith<$Res> {
  __$$VitalImplCopyWithImpl(
    _$VitalImpl _value,
    $Res Function(_$VitalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Vital
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? recordedAt = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$VitalImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        patientId:
            null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        value:
            null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                    as String,
        unit:
            null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                    as String,
        recordedAt:
            null == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VitalImpl implements _Vital {
  const _$VitalImpl({
    required this.id,
    @JsonKey(name: 'patient_id') required this.patientId,
    required this.type,
    required this.value,
    required this.unit,
    @JsonKey(name: 'recorded_at') required this.recordedAt,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$VitalImpl.fromJson(Map<String, dynamic> json) =>
      _$$VitalImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'patient_id')
  final String patientId;
  @override
  final String type;
  // 'blood_pressure', 'glucose', 'weight', 'heart_rate'
  @override
  final String value;
  // Encrypted Base64 string
  @override
  final String unit;
  @override
  @JsonKey(name: 'recorded_at')
  final DateTime recordedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Vital(id: $id, patientId: $patientId, type: $type, value: $value, unit: $unit, recordedAt: $recordedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientId,
    type,
    value,
    unit,
    recordedAt,
    createdAt,
  );

  /// Create a copy of Vital
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VitalImplCopyWith<_$VitalImpl> get copyWith =>
      __$$VitalImplCopyWithImpl<_$VitalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VitalImplToJson(this);
  }
}

abstract class _Vital implements Vital {
  const factory _Vital({
    required final String id,
    @JsonKey(name: 'patient_id') required final String patientId,
    required final String type,
    required final String value,
    required final String unit,
    @JsonKey(name: 'recorded_at') required final DateTime recordedAt,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$VitalImpl;

  factory _Vital.fromJson(Map<String, dynamic> json) = _$VitalImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'patient_id')
  String get patientId;
  @override
  String get type; // 'blood_pressure', 'glucose', 'weight', 'heart_rate'
  @override
  String get value; // Encrypted Base64 string
  @override
  String get unit;
  @override
  @JsonKey(name: 'recorded_at')
  DateTime get recordedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of Vital
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VitalImplCopyWith<_$VitalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
