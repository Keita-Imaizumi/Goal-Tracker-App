import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_tracker/features/auth/view_model/login_view_model.dart';
import 'package:uuid/uuid.dart';

import '../../auth/model/auth_service.dart';
import '../../auth/provider/auth_provider.dart';
import '../model/goal.dart';
import '../provider/goals_provider.dart';
import '../view_model/goal_view_model.dart';

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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(goalViewModelProvider.notifier).reset(); // ← 状態初期化
          _showGoalInputDialog(context, ref);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGoalInputDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    final statusController = TextEditingController();
    final user = ref.watch(userStateProvider);
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final goalState = ref.watch(goalViewModelProvider);

            String? errorMessage;
            if (goalState is AsyncError && goalState.error is String) {
              errorMessage = goalState.error as String;
            }

            return AlertDialog(
              title: const Text('目標を追加'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
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
                  onPressed: () async {
                    if (user == null) return;
                    final goal = Goal(
                      id: const Uuid().v4(),
                      title: titleController.text,
                      detail: detailController.text,
                      status: statusController.text,
                      deadline: selectedDate,
                    );
                    await ref.read(goalViewModelProvider.notifier).addGoal(goal, user.uid);

                    final updatedState = ref.read(goalViewModelProvider);
                    if (updatedState is! AsyncError && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('作成'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}


