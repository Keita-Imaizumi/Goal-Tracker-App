import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goal_tracker/features/goals/view_model/goal_view_model.dart';

import '../../auth/provider/auth_provider.dart';
import '../model/goal_service.dart';
import '../model/goals.dart';
import '../model/goal_repository.dart';

final goalRepositoryProvider = Provider((ref) => GoalRepository());
final goalListProvider = StateProvider<List<Goal>>((ref) => []);

final userGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(goalRepositoryProvider).streamGoalsForUser(user.uid);
});
final goalViewModelProvider =
StateNotifierProvider<GoalViewModel, AsyncValue<void>>((ref) {
  final service = GoalService(); // Service をここで使う
  return GoalViewModel(service);
});

