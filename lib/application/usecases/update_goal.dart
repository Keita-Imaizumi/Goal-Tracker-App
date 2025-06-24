import "package:goal_tracker/domains/features/goal_updater.dart";

import "../../domains/Irepositories/goal_repository.dart";
import "../../domains/entities/tag/tag.dart";
import "../../domains/entities/goal/goal.dart";
import "../../domains/features/goal_validater.dart";

class UpdateGoalUsecase {
  final GoalUpdater _updator;
  final IGoalRepository _goalRepository;
  UpdateGoalUsecase(this._updator, this._goalRepository);

  Future<void> updateGoal({
    required Goal oldGoal,
    required String userId,
    required String title, 
    String? detail,
    DateTime? deadline,
    List<Tag> tags = const [],
  }) async {
    // 入力値検証
    GoalValidator.validateTitleOrThrow(title);
    final newGoal = _updator.updateGoal(
      oldGoal,
      title:title,
      detail: detail,
      deadline: deadline,
      tags: tags,
    );
    await _goalRepository.updateGoal(userId, newGoal);
  }
}