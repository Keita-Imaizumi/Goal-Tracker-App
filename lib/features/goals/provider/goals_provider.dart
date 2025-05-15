import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';

import '../model/goal/goal.dart';
import '../repository/goal_repository.dart';


final goalListProvider = StateProvider<List<Goal>>((ref) => []);

final userGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(userStateProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(goalRepositoryProvider).streamGoalsForUser(user.uid);
});

