// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allCoursesHash() => r'06752242d2bfebc1c3caafbf449eec7c5b726034';

/// See also [allCourses].
@ProviderFor(allCourses)
final allCoursesProvider = AutoDisposeStreamProvider<List<Course>>.internal(
  allCourses,
  name: r'allCoursesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allCoursesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllCoursesRef = AutoDisposeStreamProviderRef<List<Course>>;
String _$currentFocusHash() => r'4f36c0b0894bc85ea30ba42fd9a6b208980e49c3';

/// See also [currentFocus].
@ProviderFor(currentFocus)
final currentFocusProvider = AutoDisposeProvider<Course?>.internal(
  currentFocus,
  name: r'currentFocusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentFocusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentFocusRef = AutoDisposeProviderRef<Course?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
