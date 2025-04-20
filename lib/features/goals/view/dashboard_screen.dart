import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../auth/model/auth_service.dart';
import '../../auth/provider/auth_provider.dart';
import '../model/goals.dart';
import '../provider/goals_provider.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(userGoalsProvider);

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
              ref.read(userProvider.notifier).state = null;

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
              title: Text(goal.title),
              subtitle: Text('状態: ${goal.status}'),
              onLongPress: () async {
                final user = ref.read(userProvider);
                if (user == null) return;

                await ref.read(goalRepositoryProvider).deleteGoal(user.uid, goal.id);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = ref.read(userProvider);
          if (user == null) return;

          final goal = Goal(
            id: const Uuid().v4(),
            title: '英単語100個覚える',
            status: 'todo',
            deadline: DateTime.now().add(const Duration(days: 3)),
          );

          await ref.read(goalRepositoryProvider).addGoal(user.uid, goal);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

