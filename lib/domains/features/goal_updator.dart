import '../../../presentation/pages/goal_list_page/goal_view_model.dart';
import '../../../domains/entities/goal/goal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalUpdator {
  final WidgetRef ref;
  GoalUpdator(this.ref);

  Future<void> update(String userId, Goal goal) async {
    await ref.read(goalViewModelProvider.notifier).updateGoal(userId, goal);
  }
}
