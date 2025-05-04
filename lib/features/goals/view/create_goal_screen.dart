import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../auth/provider/auth_provider.dart';
import '../model/goal/goal.dart';
import '../model/tag/tag.dart';
import '../view_model/goal_view_model.dart';
import '../view_model/tag_view_model.dart';

Future<void> showGoalInputBottomSheet(BuildContext context, WidgetRef ref) async {
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  // final subTaskController = TextEditingController();
  final user = ref.watch(userStateProvider);
  final allTags = await ref.read(tagViewModelProvider.notifier).fetchTags(user!.uid);
  final List<Task> subTasks = [];
  List<Tag> localAllTags = List.from(allTags);
  List<Tag> selectedTags = [];
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
                      const SizedBox(height: 16),
                      Text('タグを選択', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        runSpacing: 16,
                        spacing: 16,
                        children: localAllTags.map((tag) {
                          // selectedTags の中に自分がいるかを確かめる
                          final isSelected = selectedTags.contains(tag);
                          return InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(32)),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedTags.remove(tag);
                                } else {
                                  selectedTags.add(tag);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(32)),
                                border: Border.all(
                                  width: 2,
                                  color: Colors.pink,
                                ),
                                color: isSelected ? Colors.pink : null,
                              ),
                              child: Text(
                                tag.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.pink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                                  onPressed: () async{
                                    if (user == null) return;
                                    await ref
                                        .read(tagViewModelProvider.notifier)
                                        .createTag(user.uid, controller.text);

                                    final updatedTags = await ref
                                        .read(tagViewModelProvider.notifier)
                                        .fetchTags(user.uid);
                                    setState(() {
                                      localAllTags = updatedTags;
                                    });

                                    if (context.mounted) Navigator.of(context).pop();
                                  },
                                  child: const Text('追加'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('タグを追加'),
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
  DateTime? selectedDate = goal.deadline;
  List<String> selectedTagIds = List<String>.from(goal.tags?.map((tag) => tag.id) ?? []);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final allTags = ref.watch(tagViewModelProvider);
      final user = ref.watch(userStateProvider);
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

                  // Wrap(
                  //   runSpacing: 16,
                  //   spacing: 16,
                  //   children: allTags.map((tag) {
                  //     final isSelected = selectedTagIds.contains(tag.id);
                  //     return InkWell(
                  //       onTap: () {
                  //         setState(() {
                  //           if (isSelected) {
                  //             selectedTagIds.remove(tag.id);
                  //           } else {
                  //             selectedTagIds.add(tag.id);
                  //           }
                  //         });
                  //       },
                  //       child: AnimatedContainer(
                  //         duration: const Duration(milliseconds: 200),
                  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //         decoration: BoxDecoration(
                  //           borderRadius: const BorderRadius.all(Radius.circular(32)),
                  //           border: Border.all(
                  //             width: 2,
                  //             color: Colors.pink,
                  //           ),
                  //           color: isSelected ? Colors.pink : null,
                  //         ),
                  //         child: Text(
                  //           tag.name,
                  //           style: TextStyle(
                  //             color: isSelected ? Colors.white : Colors.pink,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   }).toList(),
                  // ),

                  // タグ追加ボタン
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
                              onPressed: () async{
                                // 新しいタグを追加する処理
                                ref.read(tagViewModelProvider.notifier).createTag(user!.uid, controller.text);
                                Navigator.pop(context);
                              },
                              child: const Text('追加'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('タグ追加'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     // selectedTagIdsからTagオブジェクトに変換
                      //     final selectedTags = allTags.where((tag) => selectedTagIds.contains(tag.id)).toList();
                      //
                      //     final updatedGoal = goal.copyWith(
                      //       title: titleController.text,
                      //       detail: detailController.text,
                      //       deadline: selectedDate,
                      //       tags: selectedTags,
                      //     );
                      //     final user = ref.read(userStateProvider);
                      //     if (user != null) {
                      //       await ref.read(goalViewModelProvider.notifier).updateGoal(user.uid, updatedGoal);
                      //     }
                      //     if (context.mounted) Navigator.pop(context);
                      //   },
                      //   child: const Text('保存'),
                      // ),
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
