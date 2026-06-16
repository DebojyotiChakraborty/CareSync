// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableDoctorsHash() => r'ea2022d296517b08a599f7b19516d1fbab07890f';

/// See also [availableDoctors].
@ProviderFor(availableDoctors)
final availableDoctorsProvider =
    AutoDisposeFutureProvider<List<UserProfile>>.internal(
      availableDoctors,
      name: r'availableDoctorsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$availableDoctorsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableDoctorsRef = AutoDisposeFutureProviderRef<List<UserProfile>>;
String _$doctorAvailabilityHash() =>
    r'dfa74d8e90fa897e52e35008134755766d08021c';

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

/// See also [doctorAvailability].
@ProviderFor(doctorAvailability)
const doctorAvailabilityProvider = DoctorAvailabilityFamily();

/// See also [doctorAvailability].
class DoctorAvailabilityFamily
    extends Family<AsyncValue<List<DoctorAvailability>>> {
  /// See also [doctorAvailability].
  const DoctorAvailabilityFamily();

  /// See also [doctorAvailability].
  DoctorAvailabilityProvider call(String doctorId) {
    return DoctorAvailabilityProvider(doctorId);
  }

  @override
  DoctorAvailabilityProvider getProviderOverride(
    covariant DoctorAvailabilityProvider provider,
  ) {
    return call(provider.doctorId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'doctorAvailabilityProvider';
}

/// See also [doctorAvailability].
class DoctorAvailabilityProvider
    extends AutoDisposeFutureProvider<List<DoctorAvailability>> {
  /// See also [doctorAvailability].
  DoctorAvailabilityProvider(String doctorId)
    : this._internal(
        (ref) => doctorAvailability(ref as DoctorAvailabilityRef, doctorId),
        from: doctorAvailabilityProvider,
        name: r'doctorAvailabilityProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$doctorAvailabilityHash,
        dependencies: DoctorAvailabilityFamily._dependencies,
        allTransitiveDependencies:
            DoctorAvailabilityFamily._allTransitiveDependencies,
        doctorId: doctorId,
      );

  DoctorAvailabilityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.doctorId,
  }) : super.internal();

  final String doctorId;

  @override
  Override overrideWith(
    FutureOr<List<DoctorAvailability>> Function(DoctorAvailabilityRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DoctorAvailabilityProvider._internal(
        (ref) => create(ref as DoctorAvailabilityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        doctorId: doctorId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DoctorAvailability>> createElement() {
    return _DoctorAvailabilityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DoctorAvailabilityProvider && other.doctorId == doctorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, doctorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DoctorAvailabilityRef
    on AutoDisposeFutureProviderRef<List<DoctorAvailability>> {
  /// The parameter `doctorId` of this provider.
  String get doctorId;
}

class _DoctorAvailabilityProviderElement
    extends AutoDisposeFutureProviderElement<List<DoctorAvailability>>
    with DoctorAvailabilityRef {
  _DoctorAvailabilityProviderElement(super.provider);

  @override
  String get doctorId => (origin as DoctorAvailabilityProvider).doctorId;
}

String _$appointmentsHash() => r'bc85d646905f51547077d7262522eea8dc021d4e';

/// See also [Appointments].
@ProviderFor(Appointments)
final appointmentsProvider =
    AutoDisposeAsyncNotifierProvider<Appointments, List<Appointment>>.internal(
      Appointments.new,
      name: r'appointmentsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$appointmentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Appointments = AutoDisposeAsyncNotifier<List<Appointment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
