import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/provider/auth_provider.dart';

import '../model/goal/goal.dart';
import '../repository/goal_repository.dart';

part 'goal_view_model.g.dart';

@riverpod
class GoalViewModel extends _$GoalViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> addGoal(Goal goal, String userId) async {
    // 入力検証（タイトルが空）
    if (goal.title
        .trim()
        .isEmpty) {
      state = AsyncError('タイトルは必須です', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      final repository = ref.read(goalRepositoryProvider);
      await repository.addGoal(userId, goal);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteGoal(String userId, String goalId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(goalRepositoryProvider);
      await repository.deleteGoal(userId, goalId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateGoal(String userId, Goal goal) async {
    final repository = ref.read(goalRepositoryProvider);
    await repository.updateGoal(userId, goal);
  }

  Future<void> toggleDone(String userId, Goal goal) async {
    final repository = ref.read(goalRepositoryProvider);
    final updatedGoal = goal.copyWith(done: !goal.done);
    await repository.updateGoal(userId, updatedGoal);
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final userGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(userStateProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(goalRepositoryProvider).streamGoalsForUser(user.uid);
});

final goalListProvider = StateProvider<List<Goal>>((ref) => []);

