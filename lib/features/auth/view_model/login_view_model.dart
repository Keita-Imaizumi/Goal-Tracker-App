import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../goals/provider/goals_provider.dart';
import '../../goals/model/goal_service.dart';
import '../model/auth_service.dart';
import '../provider/auth_provider.dart';


class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LoginViewModel(this.ref) : super(const AsyncData(null));

  void resetLoginState() {
    state = const AsyncData(null);
  }

  Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    state = const AsyncLoading();
    try {
      final user = await AuthService().signInWithEmail(email, password);
      if (user != null) {
        ref.read(userProvider.notifier).state = user;
        context.go('/dashboard/');
      } else {
        state = AsyncError('ログインに失敗しました', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    state = const AsyncLoading();
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        ref.read(userProvider.notifier).state = user;

        final goals = await GoalService().fetchGoals(user.uid);
        ref.read(goalListProvider.notifier).state = goals;

        context.go('/dashboard/');
      } else {
        state = AsyncError('Googleログインに失敗しました', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
