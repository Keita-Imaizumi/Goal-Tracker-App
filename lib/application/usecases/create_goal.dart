import "../../domains/features/goal_creater.dart";
import "../../domains/Irepositories/goal_repository.dart";
import "../../domains/entities/tag/tag.dart";

class CreateGoalUsecase {
  final GoalCreator _creator;
  final IGoalRepository _goalRepository;
  CreateGoalUsecase(this._creator, this._goalRepository);

  Future<void> createNewGoal({
    required String userId,
    required String title, 
    String? detail,
    DateTime? deadline,
    List<Tag> tags = const [],
  }) async {
    final newGoal = _creator.createGoal(
      title,
      detail: detail,
      deadline: deadline,
      tags: tags,
    );
    await _goalRepository.addGoal(userId, newGoal);
  }
}