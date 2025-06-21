import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_tracker/infrastructures/repositories/goal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../goal_list_page/goal_view_model.dart';

import '../../../features/auth/provider/auth_provider.dart';
import '../../../features/auth/service/auth_service.dart';

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
