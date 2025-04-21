import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/goal_service.dart';
import '../model/goals.dart';

class GoalViewModel extends StateNotifier<AsyncValue<void>> {
  GoalViewModel(this._service) : super(const AsyncData(null));

  final GoalService _service;

  Future<void> addGoal(Goal goal, String uid) async {
    state = const AsyncLoading();
    try {
      await _service.addGoal(uid, goal);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
