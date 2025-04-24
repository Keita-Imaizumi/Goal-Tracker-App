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
              leading: Checkbox(
                  value: goal.done,
                  onChanged: (checked){
                    final user = ref.read(userProvider);
                    if (user == null) return;
                    ref.read(goalViewModelProvider.notifier).toggleDone(user.uid, goal);
                    }),
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
        onPressed: () => _showGoalInputDialog(context, ref),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGoalInputDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    final statusController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('目標を追加'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'タイトル'),
                ),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(labelText: '詳細'),
                ),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: '状態'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                    }
                  },
                  child: const Text('締切日を選択'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(userProvider);
                if (user == null) return;

                final goal = Goal(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  detail: detailController.text,
                  status: statusController.text,
                  deadline: selectedDate,
                );

                ref
                    .read(goalViewModelProvider.notifier)
                    .addGoal(goal, user.uid);
                Navigator.of(context).pop();
              },
              child: const Text('作成'),
            ),
          ],
        );
      },
    );
  }
}


