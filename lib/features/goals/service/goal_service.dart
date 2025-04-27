import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/goal/goal.dart';
import '../model/tag/tag.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addGoal(String uid, Goal goal) async {
    final data = {
      'id': goal.id,
      'title': goal.title,
      'status': goal.status,
      'detail': goal.detail,
      'deadline': goal.deadline != null ? Timestamp.fromDate(goal.deadline!) : null,
      'done': goal.done,
      'tags': goal.tags.map((tag) => {
        'id': tag.id,
        'name': tag.name,
      }).toList(),
      'tasks': goal.tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'deadline': task.deadline != null ? Timestamp.fromDate(task.deadline!) : null,
        'done': task.done,
      }).toList(),
    };

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id)
        .set(data);
  }


  Future<void> deleteGoal(String uid, String goalId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  Future<List<Goal>> fetchGoals(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .get();

    return snapshot.docs
        .map((doc) => goalFromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<void> updateGoal(String uid, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id)
        .set(goal.toFirestore());
  }

  Goal goalFromFirestore(String id, Map<String, dynamic> data) {
    return Goal(
      id: id,
      title: data['title'] as String? ?? '',
      status: data['status'] as String? ?? '',
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
          id: map['id'] as String? ?? '', // ★修正
          title: map['title'] as String? ?? '',
          deadline: (map['deadline'] as Timestamp?)?.toDate(),
          done: map['done'] as bool? ?? false,
        );
      }).toList(),
    );
  }
}