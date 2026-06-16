// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Appointment _$AppointmentFromJson(Map<String, dynamic> json) {
  return _Appointment.fromJson(json);
}

/// @nodoc
mixin _$Appointment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_id')
  String get patientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'doctor_id')
  String get doctorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'scheduled', 'completed', 'cancelled'
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError; // Joined data
  UserProfile? get patient => throw _privateConstructorUsedError;
  UserProfile? get doctor => throw _privateConstructorUsedError;

  /// Serializes this Appointment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppointmentCopyWith<Appointment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentCopyWith<$Res> {
  factory $AppointmentCopyWith(
    Appointment value,
    $Res Function(Appointment) then,
  ) = _$AppointmentCopyWithImpl<$Res, Appointment>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'patient_id') String patientId,
    @JsonKey(name: 'doctor_id') String doctorId,
    @JsonKey(name: 'start_time') DateTime startTime,
    String status,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    UserProfile? patient,
    UserProfile? doctor,
  });
}

/// @nodoc
class _$AppointmentCopyWithImpl<$Res, $Val extends Appointment>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? startTime = null,
    Object? status = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? patient = freezed,
    Object? doctor = freezed,
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
            doctorId:
                null == doctorId
                    ? _value.doctorId
                    : doctorId // ignore: cast_nullable_to_non_nullable
                        as String,
            startTime:
                null == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            patient:
                freezed == patient
                    ? _value.patient
                    : patient // ignore: cast_nullable_to_non_nullable
                        as UserProfile?,
            doctor:
                freezed == doctor
                    ? _value.doctor
                    : doctor // ignore: cast_nullable_to_non_nullable
                        as UserProfile?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppointmentImplCopyWith<$Res>
    implements $AppointmentCopyWith<$Res> {
  factory _$$AppointmentImplCopyWith(
    _$AppointmentImpl value,
    $Res Function(_$AppointmentImpl) then,
  ) = __$$AppointmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'patient_id') String patientId,
    @JsonKey(name: 'doctor_id') String doctorId,
    @JsonKey(name: 'start_time') DateTime startTime,
    String status,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    UserProfile? patient,
    UserProfile? doctor,
  });
}

/// @nodoc
class __$$AppointmentImplCopyWithImpl<$Res>
    extends _$AppointmentCopyWithImpl<$Res, _$AppointmentImpl>
    implements _$$AppointmentImplCopyWith<$Res> {
  __$$AppointmentImplCopyWithImpl(
    _$AppointmentImpl _value,
    $Res Function(_$AppointmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? startTime = null,
    Object? status = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? patient = freezed,
    Object? doctor = freezed,
  }) {
    return _then(
      _$AppointmentImpl(
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
        doctorId:
            null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                    as String,
        startTime:
            null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        patient:
            freezed == patient
                ? _value.patient
                : patient // ignore: cast_nullable_to_non_nullable
                    as UserProfile?,
        doctor:
            freezed == doctor
                ? _value.doctor
                : doctor // ignore: cast_nullable_to_non_nullable
                    as UserProfile?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentImpl implements _Appointment {
  const _$AppointmentImpl({
    required this.id,
    @JsonKey(name: 'patient_id') required this.patientId,
    @JsonKey(name: 'doctor_id') required this.doctorId,
    @JsonKey(name: 'start_time') required this.startTime,
    this.status = 'scheduled',
    this.notes,
    @JsonKey(name: 'created_at') this.createdAt,
    this.patient,
    this.doctor,
  });

  factory _$AppointmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'patient_id')
  final String patientId;
  @override
  @JsonKey(name: 'doctor_id')
  final String doctorId;
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @override
  @JsonKey()
  final String status;
  // 'scheduled', 'completed', 'cancelled'
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  // Joined data
  @override
  final UserProfile? patient;
  @override
  final UserProfile? doctor;

  @override
  String toString() {
    return 'Appointment(id: $id, patientId: $patientId, doctorId: $doctorId, startTime: $startTime, status: $status, notes: $notes, createdAt: $createdAt, patient: $patient, doctor: $doctor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.patient, patient) || other.patient == patient) &&
            (identical(other.doctor, doctor) || other.doctor == doctor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientId,
    doctorId,
    startTime,
    status,
    notes,
    createdAt,
    patient,
    doctor,
  );

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      __$$AppointmentImplCopyWithImpl<_$AppointmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentImplToJson(this);
  }
}

abstract class _Appointment implements Appointment {
  const factory _Appointment({
    required final String id,
    @JsonKey(name: 'patient_id') required final String patientId,
    @JsonKey(name: 'doctor_id') required final String doctorId,
    @JsonKey(name: 'start_time') required final DateTime startTime,
    final String status,
    final String? notes,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final UserProfile? patient,
    final UserProfile? doctor,
  }) = _$AppointmentImpl;

  factory _Appointment.fromJson(Map<String, dynamic> json) =
      _$AppointmentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'patient_id')
  String get patientId;
  @override
  @JsonKey(name: 'doctor_id')
  String get doctorId;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;
  @override
  String get status; // 'scheduled', 'completed', 'cancelled'
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // Joined data
  @override
  UserProfile? get patient;
  @override
  UserProfile? get doctor;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DoctorAvailability _$DoctorAvailabilityFromJson(Map<String, dynamic> json) {
  return _DoctorAvailability.fromJson(json);
}

/// @nodoc
mixin _$DoctorAvailability {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'doctor_id')
  String get doctorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_week')
  int get dayOfWeek => throw _privateConstructorUsedError; // 0-6
  @JsonKey(name: 'start_time')
  String get startTime => throw _privateConstructorUsedError; // HH:mm:ss
  @JsonKey(name: 'end_time')
  String get endTime => throw _privateConstructorUsedError; // HH:mm:ss
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this DoctorAvailability to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoctorAvailabilityCopyWith<DoctorAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoctorAvailabilityCopyWith<$Res> {
  factory $DoctorAvailabilityCopyWith(
    DoctorAvailability value,
    $Res Function(DoctorAvailability) then,
  ) = _$DoctorAvailabilityCopyWithImpl<$Res, DoctorAvailability>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'doctor_id') String doctorId,
    @JsonKey(name: 'day_of_week') int dayOfWeek,
    @JsonKey(name: 'start_time') String startTime,
    @JsonKey(name: 'end_time') String endTime,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class _$DoctorAvailabilityCopyWithImpl<$Res, $Val extends DoctorAvailability>
    implements $DoctorAvailabilityCopyWith<$Res> {
  _$DoctorAvailabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? doctorId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            doctorId:
                null == doctorId
                    ? _value.doctorId
                    : doctorId // ignore: cast_nullable_to_non_nullable
                        as String,
            dayOfWeek:
                null == dayOfWeek
                    ? _value.dayOfWeek
                    : dayOfWeek // ignore: cast_nullable_to_non_nullable
                        as int,
            startTime:
                null == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as String,
            endTime:
                null == endTime
                    ? _value.endTime
                    : endTime // ignore: cast_nullable_to_non_nullable
                        as String,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DoctorAvailabilityImplCopyWith<$Res>
    implements $DoctorAvailabilityCopyWith<$Res> {
  factory _$$DoctorAvailabilityImplCopyWith(
    _$DoctorAvailabilityImpl value,
    $Res Function(_$DoctorAvailabilityImpl) then,
  ) = __$$DoctorAvailabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'doctor_id') String doctorId,
    @JsonKey(name: 'day_of_week') int dayOfWeek,
    @JsonKey(name: 'start_time') String startTime,
    @JsonKey(name: 'end_time') String endTime,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class __$$DoctorAvailabilityImplCopyWithImpl<$Res>
    extends _$DoctorAvailabilityCopyWithImpl<$Res, _$DoctorAvailabilityImpl>
    implements _$$DoctorAvailabilityImplCopyWith<$Res> {
  __$$DoctorAvailabilityImplCopyWithImpl(
    _$DoctorAvailabilityImpl _value,
    $Res Function(_$DoctorAvailabilityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? doctorId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isActive = null,
  }) {
    return _then(
      _$DoctorAvailabilityImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        doctorId:
            null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                    as String,
        dayOfWeek:
            null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                    as int,
        startTime:
            null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as String,
        endTime:
            null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                    as String,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DoctorAvailabilityImpl implements _DoctorAvailability {
  const _$DoctorAvailabilityImpl({
    required this.id,
    @JsonKey(name: 'doctor_id') required this.doctorId,
    @JsonKey(name: 'day_of_week') required this.dayOfWeek,
    @JsonKey(name: 'start_time') required this.startTime,
    @JsonKey(name: 'end_time') required this.endTime,
    @JsonKey(name: 'is_active') this.isActive = true,
  });

  factory _$DoctorAvailabilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$DoctorAvailabilityImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'doctor_id')
  final String doctorId;
  @override
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;
  // 0-6
  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  // HH:mm:ss
  @override
  @JsonKey(name: 'end_time')
  final String endTime;
  // HH:mm:ss
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'DoctorAvailability(id: $id, doctorId: $doctorId, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoctorAvailabilityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    doctorId,
    dayOfWeek,
    startTime,
    endTime,
    isActive,
  );

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoctorAvailabilityImplCopyWith<_$DoctorAvailabilityImpl> get copyWith =>
      __$$DoctorAvailabilityImplCopyWithImpl<_$DoctorAvailabilityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DoctorAvailabilityImplToJson(this);
  }
}

abstract class _DoctorAvailability implements DoctorAvailability {
  const factory _DoctorAvailability({
    required final String id,
    @JsonKey(name: 'doctor_id') required final String doctorId,
    @JsonKey(name: 'day_of_week') required final int dayOfWeek,
    @JsonKey(name: 'start_time') required final String startTime,
    @JsonKey(name: 'end_time') required final String endTime,
    @JsonKey(name: 'is_active') final bool isActive,
  }) = _$DoctorAvailabilityImpl;

  factory _DoctorAvailability.fromJson(Map<String, dynamic> json) =
      _$DoctorAvailabilityImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'doctor_id')
  String get doctorId;
  @override
  @JsonKey(name: 'day_of_week')
  int get dayOfWeek; // 0-6
  @override
  @JsonKey(name: 'start_time')
  String get startTime; // HH:mm:ss
  @override
  @JsonKey(name: 'end_time')
  String get endTime; // HH:mm:ss
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoctorAvailabilityImplCopyWith<_$DoctorAvailabilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
