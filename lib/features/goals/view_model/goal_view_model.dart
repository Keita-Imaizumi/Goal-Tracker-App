import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/goal/goal.dart';
import '../repository/goal_repository.dart';

part 'goal_view_model.g.dart';

@riverpod
class GoalViewModel extends _$GoalViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> addGoal(Goal goal, String uid) async {
    // 入力検証（タイトルが空）
    if (goal.title.trim().isEmpty) {
      state = AsyncError('タイトルは必須です', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      await ref.read(goalRepositoryProvider).addGoal(uid, goal);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    state = const AsyncLoading();
    try {
      await ref.read(goalRepositoryProvider).deleteGoal(uid, goalId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateGoal(Goal goal, String uid) async {
    await ref.read(goalRepositoryProvider).updateGoal(uid, goal);
  }

  Future<void> toggleDone(String uid, Goal goal) async {
    final updated = goal.copyWith(done: !goal.done);
    await ref.read(goalRepositoryProvider).updateGoal(uid, updated);
  }

  void reset() {
    state = const AsyncData(null);
  }
}

