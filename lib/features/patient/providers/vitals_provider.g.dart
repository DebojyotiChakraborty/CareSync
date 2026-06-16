// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredVitalsHash() => r'f7ea92037508daa38a616bf4985e7dd90a780017';

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

/// See also [filteredVitals].
@ProviderFor(filteredVitals)
const filteredVitalsProvider = FilteredVitalsFamily();

/// See also [filteredVitals].
class FilteredVitalsFamily extends Family<AsyncValue<List<Vital>>> {
  /// See also [filteredVitals].
  const FilteredVitalsFamily();

  /// See also [filteredVitals].
  FilteredVitalsProvider call(String type) {
    return FilteredVitalsProvider(type);
  }

  @override
  FilteredVitalsProvider getProviderOverride(
    covariant FilteredVitalsProvider provider,
  ) {
    return call(provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredVitalsProvider';
}

/// See also [filteredVitals].
class FilteredVitalsProvider extends AutoDisposeFutureProvider<List<Vital>> {
  /// See also [filteredVitals].
  FilteredVitalsProvider(String type)
    : this._internal(
        (ref) => filteredVitals(ref as FilteredVitalsRef, type),
        from: filteredVitalsProvider,
        name: r'filteredVitalsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$filteredVitalsHash,
        dependencies: FilteredVitalsFamily._dependencies,
        allTransitiveDependencies:
            FilteredVitalsFamily._allTransitiveDependencies,
        type: type,
      );

  FilteredVitalsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final String type;

  @override
  Override overrideWith(
    FutureOr<List<Vital>> Function(FilteredVitalsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredVitalsProvider._internal(
        (ref) => create(ref as FilteredVitalsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Vital>> createElement() {
    return _FilteredVitalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredVitalsProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredVitalsRef on AutoDisposeFutureProviderRef<List<Vital>> {
  /// The parameter `type` of this provider.
  String get type;
}

class _FilteredVitalsProviderElement
    extends AutoDisposeFutureProviderElement<List<Vital>>
    with FilteredVitalsRef {
  _FilteredVitalsProviderElement(super.provider);

  @override
  String get type => (origin as FilteredVitalsProvider).type;
}

String _$patientVitalsHash() => r'9183b0827b2b61143f134f32c9181ca65b765d84';

/// See also [PatientVitals].
@ProviderFor(PatientVitals)
final patientVitalsProvider =
    AutoDisposeAsyncNotifierProvider<PatientVitals, List<Vital>>.internal(
      PatientVitals.new,
      name: r'patientVitalsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$patientVitalsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PatientVitals = AutoDisposeAsyncNotifier<List<Vital>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
