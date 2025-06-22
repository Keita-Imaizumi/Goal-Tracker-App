import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domains/entities/goal/goal.dart';
import '../../domains/entities/tag/tag.dart';
import '../../domains/entities/task/task.dart';

Goal goalFromFirestore(String id, Map<String, dynamic> data) {
  return Goal(
    id: id,
    title: data['title'] as String? ?? '',
    detail: data['detail'] as String?,
    deadline: (data['deadline'] as Timestamp?)?.toDate(),
    done: data['done'] as bool? ?? false,
    tags: (data['tags'] as List<dynamic>? ?? []).map((tagData) {
      final map = tagData as Map<String, dynamic>;
      return Tag(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
      );
    }).toList(),
    tasks: (data['tasks'] as List<dynamic>? ?? []).map((taskData) {
      final map = taskData as Map<String, dynamic>;
      return Task(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        deadline: (map['deadline'] as Timestamp?)?.toDate(),
        done: map['done'] as bool? ?? false,
      );
    }).toList(),
  );
}

Map<String, dynamic> goalToFirestoreData(Goal goal) {
  return {
    'id': goal.id,
    'title': goal.title,
    'detail': goal.detail,
    'deadline': goal.deadline != null ? Timestamp.fromDate(goal.deadline!) : null,
    'done': goal.done,
    'tags': goal.tags.map((tag) => tag.toJson()).toList(),
    'tasks': goal.tasks.map((task) => {
      'id': task.id,
      'title': task.title,
      'deadline': task.deadline != null ? Timestamp.fromDate(task.deadline!) : null,
      'done': task.done,
    }).toList(),
  };
}
