import '../../../domains/entities/goal/goal.dart';
import '../../../domains/entities/tag/tag.dart';

// Goalを更新するためのクラス
class GoalUpdater {
  Goal updateGoal(
    Goal oldGoal, {
    required String title,
    String? detail,
    DateTime? deadline,
    List<Tag>? tags,
  }) {
    return oldGoal.copyWith(
      title: title,
      detail: detail,
      deadline: deadline,
      tags: tags ?? const [],
    );
  }
}
