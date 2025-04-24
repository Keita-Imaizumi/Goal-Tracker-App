import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/provider/auth_provider.dart';
import '../service/goal_repository.dart';
import '../service/goal_service.dart';
import '../model/goal/goal.dart';

part 'goals_provider.g.dart';

final goalRepositoryProvider = Provider((ref) => GoalRepository());
final goalListProvider = StateProvider<List<Goal>>((ref) => []);

final userGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(userStateProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(goalRepositoryProvider).streamGoalsForUser(user.uid);
});
@riverpod
GoalService goalService(GoalServiceRef ref) {
  return GoalService();
}

