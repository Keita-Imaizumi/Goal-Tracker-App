import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../auth/provider/auth_provider.dart';
import '../model/goal/goal.dart';
import '../model/tag/tag.dart';
import '../view_model/goal_view_model.dart';
import '../view_model/tag_view_model.dart';

void showGoalInputBottomSheet(BuildContext context, WidgetRef ref) {
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  final statusController = TextEditingController();
  final subTaskController = TextEditingController();
  final user = ref.watch(userStateProvider);
  final List<Task> subTasks = [];
  List<Tag> selectedTags = []; // ← 変更点
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
            final tags = ref.watch(tagViewModelProvider);

            String? errorMessage;
            if (goalState is AsyncError && goalState.error is String) {
              errorMessage = goalState.error as String;
            }

            return StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('目標を追加', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      const SizedBox(height: 16),
                      Text('タグを選択', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: tags.map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return CheckboxListTile(
                            title: Text(tag.name),
                            value: isSelected,
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedTags.add(tag);
                                } else {
                                  selectedTags.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      TextButton(
                        onPressed: () {
                          final controller = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('タグを追加'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(labelText: 'タグ名'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('キャンセル'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(tagViewModelProvider.notifier).addTag(controller.text);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('追加'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('タグを追加'),
                      ),

                      const Divider(),

                      TextField(
                        controller: subTaskController,
                        decoration: const InputDecoration(
                          labelText: '小タスクを追加（Enterで追加）',
                        ),
                        onSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            DateTime? pickedDeadline = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            setState(() {
                              subTasks.add(Task(
                                id: const Uuid().v4(),
                                title: value,
                                deadline: pickedDeadline,
                              ));
                              subTaskController.clear();
                            });
                          }
                        },

                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subTasks.length,
                        itemBuilder: (_, index) {
                          final subTask = subTasks[index];
                          return CheckboxListTile(
                            title: Text(subTask.title),
                            value: subTask.done,
                            onChanged: (val) {
                              setState(() {
                                subTasks[index] = subTask.copyWith(done: val ?? false);
                              });
                            },
                          );
                        },
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
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: const Text('日付選択'),
                          ),
                        ],
                      ),

                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
                        ),

                      const SizedBox(height: 16),
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
                                tags: selectedTags,
                                tasks: subTasks,
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
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

void showEditGoalBottomSheet(BuildContext context, WidgetRef ref, Goal goal) {
  final titleController = TextEditingController(text: goal.title);
  final detailController = TextEditingController(text: goal.detail ?? '');
  final statusController = TextEditingController(text: goal.status);
  DateTime? selectedDate = goal.deadline;
  List<Task> subTasks = List<Task>.from(goal.tasks);
  List<Tag> selectedTags = List<Tag>.from(goal.tags);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('目標を編集', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 16),
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
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() => selectedDate = pickedDate);
                          }
                        },
                        child: const Text('日付選択'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final updatedGoal = goal.copyWith(
                            title: titleController.text,
                            detail: detailController.text,
                            status: statusController.text,
                            deadline: selectedDate,
                            tasks: subTasks,
                            tags: selectedTags,
                          );
                          final user = ref.read(userStateProvider);
                          if (user != null) {
                            await ref.read(goalViewModelProvider.notifier).updateGoal(user.uid, updatedGoal);
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
