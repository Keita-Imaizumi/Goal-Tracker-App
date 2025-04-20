import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';
import '../model/goals.dart';
import '../services/goal_repository.dart';

final goalRepositoryProvider = Provider((ref) => GoalRepository());
final goalListProvider = StateProvider<List<Goal>>((ref) => []);

final userGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(goalRepositoryProvider).streamGoalsForUser(user.uid);
});
