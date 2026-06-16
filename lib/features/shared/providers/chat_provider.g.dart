// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomMessagesHash() => r'0898ee4ea8a13864a526b3cc5663cacf76dc6d48';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [roomMessages].
@ProviderFor(roomMessages)
const roomMessagesProvider = RoomMessagesFamily();

/// See also [roomMessages].
class RoomMessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [roomMessages].
  const RoomMessagesFamily();

  /// See also [roomMessages].
  RoomMessagesProvider call(String roomId) {
    return RoomMessagesProvider(roomId);
  }

  @override
  RoomMessagesProvider getProviderOverride(
    covariant RoomMessagesProvider provider,
  ) {
    return call(provider.roomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roomMessagesProvider';
}

/// See also [roomMessages].
class RoomMessagesProvider extends AutoDisposeStreamProvider<List<Message>> {
  /// See also [roomMessages].
  RoomMessagesProvider(String roomId)
    : this._internal(
        (ref) => roomMessages(ref as RoomMessagesRef, roomId),
        from: roomMessagesProvider,
        name: r'roomMessagesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$roomMessagesHash,
        dependencies: RoomMessagesFamily._dependencies,
        allTransitiveDependencies:
            RoomMessagesFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  RoomMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  Override overrideWith(
    Stream<List<Message>> Function(RoomMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomMessagesProvider._internal(
        (ref) => create(ref as RoomMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Message>> createElement() {
    return _RoomMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomMessagesProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoomMessagesRef on AutoDisposeStreamProviderRef<List<Message>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<Message>>
    with RoomMessagesRef {
  _RoomMessagesProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomMessagesProvider).roomId;
}

String _$chatRoomsHash() => r'34e5b342e0ee86723363996b5f03993173bf04cb';

/// See also [ChatRooms].
@ProviderFor(ChatRooms)
final chatRoomsProvider =
    AutoDisposeAsyncNotifierProvider<ChatRooms, List<ChatRoom>>.internal(
      ChatRooms.new,
      name: r'chatRoomsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$chatRoomsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatRooms = AutoDisposeAsyncNotifier<List<ChatRoom>>;
String _$chatControllerHash() => r'318bc8bcc42ae75aa40d137cd5694a8616dc5152';

/// See also [ChatController].
@ProviderFor(ChatController)
final chatControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChatController, void>.internal(
      ChatController.new,
      name: r'chatControllerProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$chatControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
