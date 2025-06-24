import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/auth/provider/auth_provider.dart';

import '../../../domains/entities/goal/goal.dart';
import '../../../domains/entities/tag/tag.dart';
import '../../../infrastructures/repositories/goal_repository.dart';
import '../../../application/usecases/create_goal.dart';
import '../../../domains/features/goal_creater.dart';

part 'goal_view_model.g.dart';

final createGoalUseCaseProvider = Provider<CreateGoalUsecase>((ref) {
  final goalCreator = GoalCreator();
  final goalRepository = ref.read(goalRepositoryProvider);
  return CreateGoalUsecase(goalCreator, goalRepository);
});

@riverpod
class GoalViewModel extends _$GoalViewModel {
  late final CreateGoalUsecase _createGoalUseCase = ref.read(createGoalUseCaseProvider);

  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }
  //ゴール新規作成メソッド（クリーンアーキテクチャ導入Ver）
  Future<void> createGoal({
    required String title,
    String? detail,
    DateTime? deadline,
    List<Tag> tags = const [],
  }) async {
    final user = ref.read(userStateProvider);    
    state = const AsyncLoading();
    try {
      await _createGoalUseCase.createNewGoal(
        userId: user!.uid,
        title: title,
        detail: detail,
        deadline: deadline,
        tags: tags,
      ); 
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final user = ref.read(userStateProvider);
    state = const AsyncLoading();
    try {
      final repository = ref.read(goalRepositoryProvider);
      await repository.deleteGoal(user!.uid, goalId);
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

@riverpod
Stream<List<Goal>> userGoals(UserGoalsRef ref) {
  final user = ref.watch(userStateProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(goalRepositoryProvider).streamGoalsForUser(user.uid);
}

@riverpod
class GoalList extends _$GoalList {
  @override
  List<Goal> build() => [];
}

