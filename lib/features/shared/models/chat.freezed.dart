// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) {
  return _ChatRoom.fromJson(json);
}

/// @nodoc
mixin _$ChatRoom {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_id')
  String get patientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'doctor_id')
  String get doctorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_at')
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError; // Joined data
  UserProfile? get patient => throw _privateConstructorUsedError;
  UserProfile? get doctor => throw _privateConstructorUsedError;
  Message? get lastMessage => throw _privateConstructorUsedError;

  /// Serializes this ChatRoom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomCopyWith<ChatRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomCopyWith<$Res> {
  factory $ChatRoomCopyWith(ChatRoom value, $Res Function(ChatRoom) then) =
      _$ChatRoomCopyWithImpl<$Res, ChatRoom>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'patient_id') String patientId,
    @JsonKey(name: 'doctor_id') String doctorId,
    @JsonKey(name: 'last_message_at') DateTime lastMessageAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    UserProfile? patient,
    UserProfile? doctor,
    Message? lastMessage,
  });

  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$ChatRoomCopyWithImpl<$Res, $Val extends ChatRoom>
    implements $ChatRoomCopyWith<$Res> {
  _$ChatRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? lastMessageAt = null,
    Object? createdAt = freezed,
    Object? patient = freezed,
    Object? doctor = freezed,
    Object? lastMessage = freezed,
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
            lastMessageAt:
                null == lastMessageAt
                    ? _value.lastMessageAt
                    : lastMessageAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
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
            lastMessage:
                freezed == lastMessage
                    ? _value.lastMessage
                    : lastMessage // ignore: cast_nullable_to_non_nullable
                        as Message?,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRoomImplCopyWith<$Res>
    implements $ChatRoomCopyWith<$Res> {
  factory _$$ChatRoomImplCopyWith(
    _$ChatRoomImpl value,
    $Res Function(_$ChatRoomImpl) then,
  ) = __$$ChatRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'patient_id') String patientId,
    @JsonKey(name: 'doctor_id') String doctorId,
    @JsonKey(name: 'last_message_at') DateTime lastMessageAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    UserProfile? patient,
    UserProfile? doctor,
    Message? lastMessage,
  });

  @override
  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$ChatRoomImplCopyWithImpl<$Res>
    extends _$ChatRoomCopyWithImpl<$Res, _$ChatRoomImpl>
    implements _$$ChatRoomImplCopyWith<$Res> {
  __$$ChatRoomImplCopyWithImpl(
    _$ChatRoomImpl _value,
    $Res Function(_$ChatRoomImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? lastMessageAt = null,
    Object? createdAt = freezed,
    Object? patient = freezed,
    Object? doctor = freezed,
    Object? lastMessage = freezed,
  }) {
    return _then(
      _$ChatRoomImpl(
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
        lastMessageAt:
            null == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
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
        lastMessage:
            freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                    as Message?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomImpl implements _ChatRoom {
  const _$ChatRoomImpl({
    required this.id,
    @JsonKey(name: 'patient_id') required this.patientId,
    @JsonKey(name: 'doctor_id') required this.doctorId,
    @JsonKey(name: 'last_message_at') required this.lastMessageAt,
    @JsonKey(name: 'created_at') this.createdAt,
    this.patient,
    this.doctor,
    this.lastMessage,
  });

  factory _$ChatRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'patient_id')
  final String patientId;
  @override
  @JsonKey(name: 'doctor_id')
  final String doctorId;
  @override
  @JsonKey(name: 'last_message_at')
  final DateTime lastMessageAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  // Joined data
  @override
  final UserProfile? patient;
  @override
  final UserProfile? doctor;
  @override
  final Message? lastMessage;

  @override
  String toString() {
    return 'ChatRoom(id: $id, patientId: $patientId, doctorId: $doctorId, lastMessageAt: $lastMessageAt, createdAt: $createdAt, patient: $patient, doctor: $doctor, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.patient, patient) || other.patient == patient) &&
            (identical(other.doctor, doctor) || other.doctor == doctor) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientId,
    doctorId,
    lastMessageAt,
    createdAt,
    patient,
    doctor,
    lastMessage,
  );

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith =>
      __$$ChatRoomImplCopyWithImpl<_$ChatRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomImplToJson(this);
  }
}

abstract class _ChatRoom implements ChatRoom {
  const factory _ChatRoom({
    required final String id,
    @JsonKey(name: 'patient_id') required final String patientId,
    @JsonKey(name: 'doctor_id') required final String doctorId,
    @JsonKey(name: 'last_message_at') required final DateTime lastMessageAt,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final UserProfile? patient,
    final UserProfile? doctor,
    final Message? lastMessage,
  }) = _$ChatRoomImpl;

  factory _ChatRoom.fromJson(Map<String, dynamic> json) =
      _$ChatRoomImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'patient_id')
  String get patientId;
  @override
  @JsonKey(name: 'doctor_id')
  String get doctorId;
  @override
  @JsonKey(name: 'last_message_at')
  DateTime get lastMessageAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // Joined data
  @override
  UserProfile? get patient;
  @override
  UserProfile? get doctor;
  @override
  Message? get lastMessage;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_id')
  String get roomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_id')
  String get senderId => throw _privateConstructorUsedError;
  String get content =>
      throw _privateConstructorUsedError; // Encrypted Base64 string
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'room_id') String roomId,
    @JsonKey(name: 'sender_id') String senderId,
    String content,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? content = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            roomId:
                null == roomId
                    ? _value.roomId
                    : roomId // ignore: cast_nullable_to_non_nullable
                        as String,
            senderId:
                null == senderId
                    ? _value.senderId
                    : senderId // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
    _$MessageImpl value,
    $Res Function(_$MessageImpl) then,
  ) = __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'room_id') String roomId,
    @JsonKey(name: 'sender_id') String senderId,
    String content,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
    _$MessageImpl _value,
    $Res Function(_$MessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? content = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$MessageImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        roomId:
            null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                    as String,
        senderId:
            null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl({
    required this.id,
    @JsonKey(name: 'room_id') required this.roomId,
    @JsonKey(name: 'sender_id') required this.senderId,
    required this.content,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'room_id')
  final String roomId;
  @override
  @JsonKey(name: 'sender_id')
  final String senderId;
  @override
  final String content;
  // Encrypted Base64 string
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Message(id: $id, roomId: $roomId, senderId: $senderId, content: $content, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, roomId, senderId, content, createdAt);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(this);
  }
}

abstract class _Message implements Message {
  const factory _Message({
    required final String id,
    @JsonKey(name: 'room_id') required final String roomId,
    @JsonKey(name: 'sender_id') required final String senderId,
    required final String content,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'room_id')
  String get roomId;
  @override
  @JsonKey(name: 'sender_id')
  String get senderId;
  @override
  String get content; // Encrypted Base64 string
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
