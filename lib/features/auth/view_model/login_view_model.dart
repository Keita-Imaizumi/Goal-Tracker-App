import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../goals/provider/goals_provider.dart';
import '../../goals/service/goal_service.dart';
import '../model/auth_service.dart';
import '../provider/auth_provider.dart';

part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  void resetLoginState() {
    state = const AsyncData(null);
  }

  Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    state = const AsyncLoading();
    try {
      final user = await AuthService().signInWithEmail(email, password);
      if (user != null) {
        ref.read(userStateProvider.notifier).state = user;
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
        ref.read(userStateProvider.notifier).state = user;

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
