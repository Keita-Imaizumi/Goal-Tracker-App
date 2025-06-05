// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userGoalsHash() => r'a097003a32b77ad0b97d2ff7d3d5255b16abbf02';

/// See also [userGoals].
@ProviderFor(userGoals)
final userGoalsProvider = AutoDisposeStreamProvider<List<Goal>>.internal(
  userGoals,
  name: r'userGoalsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userGoalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserGoalsRef = AutoDisposeStreamProviderRef<List<Goal>>;
String _$goalViewModelHash() => r'9725c34f3b199808ebbb10d3d91b718cdb144451';

/// See also [GoalViewModel].
@ProviderFor(GoalViewModel)
final goalViewModelProvider =
    AutoDisposeNotifierProvider<GoalViewModel, AsyncValue<void>>.internal(
      GoalViewModel.new,
      name: r'goalViewModelProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$goalViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GoalViewModel = AutoDisposeNotifier<AsyncValue<void>>;
String _$goalListHash() => r'8f58b6b12b593db4524e1eb27386869f69675e40';

/// See also [GoalList].
@ProviderFor(GoalList)
final goalListProvider =
    AutoDisposeNotifierProvider<GoalList, List<Goal>>.internal(
      GoalList.new,
      name: r'goalListProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product') ? null : _$goalListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GoalList = AutoDisposeNotifier<List<Goal>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
