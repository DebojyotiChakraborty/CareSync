// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_patient_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$doctorPatientDataHash() => r'9644cfac20e2752740c770fc514fbf2bfc3de847';

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

/// See also [doctorPatientData].
@ProviderFor(doctorPatientData)
const doctorPatientDataProvider = DoctorPatientDataFamily();

/// See also [doctorPatientData].
class DoctorPatientDataFamily extends Family<AsyncValue<PatientData?>> {
  /// See also [doctorPatientData].
  const DoctorPatientDataFamily();

  /// See also [doctorPatientData].
  DoctorPatientDataProvider call(String userId) {
    return DoctorPatientDataProvider(userId);
  }

  @override
  DoctorPatientDataProvider getProviderOverride(
    covariant DoctorPatientDataProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'doctorPatientDataProvider';
}

/// See also [doctorPatientData].
class DoctorPatientDataProvider
    extends AutoDisposeFutureProvider<PatientData?> {
  /// See also [doctorPatientData].
  DoctorPatientDataProvider(String userId)
    : this._internal(
        (ref) => doctorPatientData(ref as DoctorPatientDataRef, userId),
        from: doctorPatientDataProvider,
        name: r'doctorPatientDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$doctorPatientDataHash,
        dependencies: DoctorPatientDataFamily._dependencies,
        allTransitiveDependencies:
            DoctorPatientDataFamily._allTransitiveDependencies,
        userId: userId,
      );

  DoctorPatientDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<PatientData?> Function(DoctorPatientDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DoctorPatientDataProvider._internal(
        (ref) => create(ref as DoctorPatientDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PatientData?> createElement() {
    return _DoctorPatientDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DoctorPatientDataProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DoctorPatientDataRef on AutoDisposeFutureProviderRef<PatientData?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _DoctorPatientDataProviderElement
    extends AutoDisposeFutureProviderElement<PatientData?>
    with DoctorPatientDataRef {
  _DoctorPatientDataProviderElement(super.provider);

  @override
  String get userId => (origin as DoctorPatientDataProvider).userId;
}

String _$doctorPatientVitalsHash() =>
    r'd9ebce3252111221b5adce407e710085b26353ee';

/// See also [doctorPatientVitals].
@ProviderFor(doctorPatientVitals)
const doctorPatientVitalsProvider = DoctorPatientVitalsFamily();

/// See also [doctorPatientVitals].
class DoctorPatientVitalsFamily extends Family<AsyncValue<List<Vital>>> {
  /// See also [doctorPatientVitals].
  const DoctorPatientVitalsFamily();

  /// See also [doctorPatientVitals].
  DoctorPatientVitalsProvider call(String patientId) {
    return DoctorPatientVitalsProvider(patientId);
  }

  @override
  DoctorPatientVitalsProvider getProviderOverride(
    covariant DoctorPatientVitalsProvider provider,
  ) {
    return call(provider.patientId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'doctorPatientVitalsProvider';
}

/// See also [doctorPatientVitals].
class DoctorPatientVitalsProvider
    extends AutoDisposeFutureProvider<List<Vital>> {
  /// See also [doctorPatientVitals].
  DoctorPatientVitalsProvider(String patientId)
    : this._internal(
        (ref) => doctorPatientVitals(ref as DoctorPatientVitalsRef, patientId),
        from: doctorPatientVitalsProvider,
        name: r'doctorPatientVitalsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$doctorPatientVitalsHash,
        dependencies: DoctorPatientVitalsFamily._dependencies,
        allTransitiveDependencies:
            DoctorPatientVitalsFamily._allTransitiveDependencies,
        patientId: patientId,
      );

  DoctorPatientVitalsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.patientId,
  }) : super.internal();

  final String patientId;

  @override
  Override overrideWith(
    FutureOr<List<Vital>> Function(DoctorPatientVitalsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DoctorPatientVitalsProvider._internal(
        (ref) => create(ref as DoctorPatientVitalsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        patientId: patientId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Vital>> createElement() {
    return _DoctorPatientVitalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DoctorPatientVitalsProvider && other.patientId == patientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, patientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DoctorPatientVitalsRef on AutoDisposeFutureProviderRef<List<Vital>> {
  /// The parameter `patientId` of this provider.
  String get patientId;
}

class _DoctorPatientVitalsProviderElement
    extends AutoDisposeFutureProviderElement<List<Vital>>
    with DoctorPatientVitalsRef {
  _DoctorPatientVitalsProviderElement(super.provider);

  @override
  String get patientId => (origin as DoctorPatientVitalsProvider).patientId;
}

String _$doctorPatientPrescriptionsHash() =>
    r'9a944c4f28c2d9b0c0fe8cbdc41c3ea9c44242a0';

/// See also [doctorPatientPrescriptions].
@ProviderFor(doctorPatientPrescriptions)
const doctorPatientPrescriptionsProvider = DoctorPatientPrescriptionsFamily();

/// See also [doctorPatientPrescriptions].
class DoctorPatientPrescriptionsFamily
    extends Family<AsyncValue<List<Prescription>>> {
  /// See also [doctorPatientPrescriptions].
  const DoctorPatientPrescriptionsFamily();

  /// See also [doctorPatientPrescriptions].
  DoctorPatientPrescriptionsProvider call(String patientId) {
    return DoctorPatientPrescriptionsProvider(patientId);
  }

  @override
  DoctorPatientPrescriptionsProvider getProviderOverride(
    covariant DoctorPatientPrescriptionsProvider provider,
  ) {
    return call(provider.patientId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'doctorPatientPrescriptionsProvider';
}

/// See also [doctorPatientPrescriptions].
class DoctorPatientPrescriptionsProvider
    extends AutoDisposeFutureProvider<List<Prescription>> {
  /// See also [doctorPatientPrescriptions].
  DoctorPatientPrescriptionsProvider(String patientId)
    : this._internal(
        (ref) => doctorPatientPrescriptions(
          ref as DoctorPatientPrescriptionsRef,
          patientId,
        ),
        from: doctorPatientPrescriptionsProvider,
        name: r'doctorPatientPrescriptionsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$doctorPatientPrescriptionsHash,
        dependencies: DoctorPatientPrescriptionsFamily._dependencies,
        allTransitiveDependencies:
            DoctorPatientPrescriptionsFamily._allTransitiveDependencies,
        patientId: patientId,
      );

  DoctorPatientPrescriptionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.patientId,
  }) : super.internal();

  final String patientId;

  @override
  Override overrideWith(
    FutureOr<List<Prescription>> Function(
      DoctorPatientPrescriptionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DoctorPatientPrescriptionsProvider._internal(
        (ref) => create(ref as DoctorPatientPrescriptionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        patientId: patientId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Prescription>> createElement() {
    return _DoctorPatientPrescriptionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DoctorPatientPrescriptionsProvider &&
        other.patientId == patientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, patientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DoctorPatientPrescriptionsRef
    on AutoDisposeFutureProviderRef<List<Prescription>> {
  /// The parameter `patientId` of this provider.
  String get patientId;
}

class _DoctorPatientPrescriptionsProviderElement
    extends AutoDisposeFutureProviderElement<List<Prescription>>
    with DoctorPatientPrescriptionsRef {
  _DoctorPatientPrescriptionsProviderElement(super.provider);

  @override
  String get patientId =>
      (origin as DoctorPatientPrescriptionsProvider).patientId;
}

String _$doctorPatientConditionsHash() =>
    r'c80c90c023facfe9167d38ee1879ae3236442e20';

/// See also [doctorPatientConditions].
@ProviderFor(doctorPatientConditions)
const doctorPatientConditionsProvider = DoctorPatientConditionsFamily();

/// See also [doctorPatientConditions].
class DoctorPatientConditionsFamily
    extends Family<AsyncValue<List<MedicalCondition>>> {
  /// See also [doctorPatientConditions].
  const DoctorPatientConditionsFamily();

  /// See also [doctorPatientConditions].
  DoctorPatientConditionsProvider call(String patientId) {
    return DoctorPatientConditionsProvider(patientId);
  }

  @override
  DoctorPatientConditionsProvider getProviderOverride(
    covariant DoctorPatientConditionsProvider provider,
  ) {
    return call(provider.patientId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'doctorPatientConditionsProvider';
}

/// See also [doctorPatientConditions].
class DoctorPatientConditionsProvider
    extends AutoDisposeFutureProvider<List<MedicalCondition>> {
  /// See also [doctorPatientConditions].
  DoctorPatientConditionsProvider(String patientId)
    : this._internal(
        (ref) => doctorPatientConditions(
          ref as DoctorPatientConditionsRef,
          patientId,
        ),
        from: doctorPatientConditionsProvider,
        name: r'doctorPatientConditionsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$doctorPatientConditionsHash,
        dependencies: DoctorPatientConditionsFamily._dependencies,
        allTransitiveDependencies:
            DoctorPatientConditionsFamily._allTransitiveDependencies,
        patientId: patientId,
      );

  DoctorPatientConditionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.patientId,
  }) : super.internal();

  final String patientId;

  @override
  Override overrideWith(
    FutureOr<List<MedicalCondition>> Function(
      DoctorPatientConditionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DoctorPatientConditionsProvider._internal(
        (ref) => create(ref as DoctorPatientConditionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        patientId: patientId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MedicalCondition>> createElement() {
    return _DoctorPatientConditionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DoctorPatientConditionsProvider &&
        other.patientId == patientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, patientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DoctorPatientConditionsRef
    on AutoDisposeFutureProviderRef<List<MedicalCondition>> {
  /// The parameter `patientId` of this provider.
  String get patientId;
}

class _DoctorPatientConditionsProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicalCondition>>
    with DoctorPatientConditionsRef {
  _DoctorPatientConditionsProviderElement(super.provider);

  @override
  String get patientId => (origin as DoctorPatientConditionsProvider).patientId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
