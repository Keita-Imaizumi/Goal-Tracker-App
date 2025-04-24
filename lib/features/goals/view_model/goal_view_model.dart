import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/goal/goal.dart';
import '../provider/goals_provider.dart';

part 'goal_view_model.g.dart';

@riverpod
class GoalViewModel extends _$GoalViewModel {
  @override
  AsyncValue<void> build() {
    // 初期値を返す（初期ロードなしなら null）
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
      await ref.read(goalServiceProvider).addGoal(uid, goal);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    state = const AsyncLoading();
    try {
      await ref.read(goalServiceProvider).deleteGoal(uid, goalId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleDone(String uid, Goal goal) async {
    final updated = goal.copyWith(done: !goal.done);
    await ref.read(goalServiceProvider).updateGoal(uid, updated);
  }

  void reset() {
    state = const AsyncData(null);
  }
}

