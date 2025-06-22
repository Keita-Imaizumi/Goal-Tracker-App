import '../entities/goal/goal.dart';

abstract class IGoalRepository {
  Stream<List<Goal>> streamGoalsForUser(String userId);
  Future<void> addGoal(String userId, Goal goal);
  Future<void> deleteGoal(String userId, String goalId);
  Future<List<Goal>> fetchGoals(String userId);
  Future<void> updateGoal(String userId, Goal goal);
}