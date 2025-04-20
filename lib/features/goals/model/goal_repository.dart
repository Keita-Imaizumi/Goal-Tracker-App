import 'package:cloud_firestore/cloud_firestore.dart';

import 'goals.dart';

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
          .map((doc) => Goal.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// ➕ ゴールを追加
  Future<void> addGoal(String uid, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id)
        .set({
      'title': goal.title,
      'status': goal.status,
      'deadline': goal.deadline,
    });
  }

  /// 🔁 ゴールを更新
  Future<void> updateGoal(String uid, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id)
        .update({
      'title': goal.title,
      'status': goal.status,
      'deadline': goal.deadline,
    });
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
}

