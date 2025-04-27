import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_tracker/features/auth/view_model/login_view_model.dart';
import 'package:goal_tracker/features/goals/view_model/tag_view_model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../auth/model/auth_service.dart';
import '../../auth/provider/auth_provider.dart';
import '../model/goal/goal.dart';
import '../model/tag/tag.dart';
import '../provider/goals_provider.dart';
import '../view_model/goal_view_model.dart';
import 'create_goal_screen.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(userGoalsProvider);
    final user = ref.watch(userStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイゴール'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              // Googleサインアウト処理
              await AuthService().signOut();
              ref.read(userStateProvider.notifier).setUser(user);
              final viewModel = ref.read(loginViewModelProvider.notifier);
              viewModel.resetLoginState();

              // 任意: ログイン画面へ戻る
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (goals) => ListView.builder(
          itemCount: goals.length,
          itemBuilder: (_, index) {
            final goal = goals[index];
            return ListTile(
              leading: Checkbox(
                  value: goal.done,
                  onChanged: (checked) async{
                    if (user == null) return;
                    await ref.read(goalViewModelProvider.notifier).toggleDone(user.uid, goal);
                    }),
              title: Text(goal.title),
              subtitle: Text('詳細: ${goal.detail}'),
              onLongPress: () async {
                if (user == null) return;
                await ref.read(goalViewModelProvider.notifier).deleteGoal(user.uid, goal.id);
              },
              onTap: () {
                showEditGoalBottomSheet(context, ref, goal);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(goalViewModelProvider.notifier).reset(); // ← 状態初期化
          showGoalInputBottomSheet(context, ref);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}


