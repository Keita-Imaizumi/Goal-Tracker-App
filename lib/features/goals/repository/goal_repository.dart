import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/goal/goal.dart';
import '../model/tag/tag.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔁 リアルタイムでゴール一覧を取得
  Stream<List<Goal>> streamGoalsForUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .orderBy('deadline', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => goalFromFirestore(doc.id, doc.data()))
          .toList();
    });
  }
  /// 🔼 ゴールを追加
  Future<void> addGoal(String uid, Goal goal) async {
    final data = _goalToFirestoreData(goal);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id)
        .set(data);
  }

  /// ❌ ゴールを削除
  Future<void> deleteGoal(String uid, String goalId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  /// 🔽 一括取得（リアルタイムではない）
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

  /// 🛠 ゴールを更新
  Future<void> updateGoal(String uid, Goal goal) async {
    final data = _goalToFirestoreData(goal);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id)
        .update(data);
  }

  /// 🧩 Goal の変換処理
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

  /// 🔃 Goal → Firestore 形式
  Map<String, dynamic> _goalToFirestoreData(Goal goal) {
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
}

