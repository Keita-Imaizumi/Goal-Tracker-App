import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/auth/provider/auth_provider.dart';
import '../../../domains/entities/goal/goal.dart';
import '../../../domains/entities/tag/tag.dart';
import '../../../domains/entities/task/task.dart';
import 'goal_view_model.dart';
import 'tag_view_model.dart';

Future<void> showGoalBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  Goal? goal,
}) async {
  final user = ref.watch(userStateProvider);
  final allTags = await ref.read(tagViewModelProvider.notifier).fetchTags(user!.uid);

  final titleController = TextEditingController(text: goal?.title ?? '');
  final detailController = TextEditingController(text: goal?.detail ?? '');
  List<Tag> localAllTags = List.from(allTags);
  List<Tag> selectedTags = List.from(goal?.tags ?? []);
  DateTime? selectedDate = goal?.deadline;
  List<Task> subTasks = List.from(goal?.tasks ?? []);

  // StatefulBuilderの外で宣言し、setStateで更新できるようにする
  String? errorMessage;

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
                  Text(
                    goal == null ? '目標を追加' : '目標を編集',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: (errorMessage?.isNotEmpty ?? false)
                          ? '$errorMessage'
                          : 'タイトル',
                      labelStyle: (errorMessage?.isNotEmpty ?? false)
                          ? const TextStyle(color: Colors.red)
                          : null,
                    ),
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
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => selectedDate = picked);
                        },
                        child: const Text('日付選択'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: localAllTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            isSelected ? selectedTags.remove(tag) : selectedTags.add(tag);
                          });
                        },
                        borderRadius: BorderRadius.circular(32),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.pink, width: 2),
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
                              onPressed: () async {
                                await ref
                                    .read(tagViewModelProvider.notifier)
                                    .createTag(user.uid, controller.text);

                                final updatedTags = await ref
                                    .read(tagViewModelProvider.notifier)
                                    .fetchTags(user.uid);
                                setState(() => localAllTags = updatedTags);

                                if (context.mounted) Navigator.pop(context);
                              },
                              child: const Text('追加'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('タグ追加'),
                  ),

                  if (goal == null)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subTasks.length,
                      itemBuilder: (_, index) {
                        final task = subTasks[index];
                        return CheckboxListTile(
                          title: Text(task.title),
                          value: task.done,
                          onChanged: (val) {
                            setState(() {
                              subTasks[index] = task.copyWith(done: val ?? false);
                            });
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            if (goal == null) {
                              await ref.read(goalViewModelProvider.notifier).createGoal(
                                title: titleController.text,
                                detail: detailController.text,
                                deadline: selectedDate,
                                tags: selectedTags,
                              );
                            } else {
                              await ref.read(goalViewModelProvider.notifier).updateGoal(
                                oldGoal: goal,
                                title: titleController.text,
                                detail: detailController.text,
                                deadline: selectedDate,
                                tags: selectedTags,
                                );
                            }
                            final updatedState = ref.read(goalViewModelProvider);
                            if (updatedState is! AsyncError && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            setState(() {
                              errorMessage = e.toString().replaceFirst('Exception: ', '');
                            });
                          }
                        },
                        child: Text(goal == null ? '作成' : '保存'),
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
