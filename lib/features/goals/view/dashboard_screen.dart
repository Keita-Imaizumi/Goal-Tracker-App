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
          _showGoalInputBottomSheet(context, ref);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGoalInputBottomSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    final statusController = TextEditingController();
    final user = ref.watch(userStateProvider);
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Consumer(
            builder: (context, ref, _) {
              final goalState = ref.watch(goalViewModelProvider);
              String? errorMessage;
              if (goalState is AsyncError && goalState.error is String) {
                errorMessage = goalState.error as String;
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '目標を追加',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate != null
                                ? '締切日: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                                : '締切日が選択されていません',
                          ),
                        ),
                        TextButton(
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
                          child: const Text('日付選択'),
                        ),
                      ],
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
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
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


}


