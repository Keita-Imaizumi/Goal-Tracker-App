import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_tracker/features/goals/repository/goal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../goals/view_model/goal_view_model.dart';

import '../provider/auth_provider.dart';
import '../service/auth_service.dart';

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

        final goalRepository = ref.read(goalRepositoryProvider);
        final goals = await goalRepository.fetchGoals(user.uid);
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
