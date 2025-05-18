import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/goal_mapper.dart';
import '../model/goal/goal.dart';

part 'goal_repository.g.dart';
@riverpod
GoalRepository goalRepository(Ref ref) {
  return GoalRepository(FirebaseFirestore.instance);
}

class GoalRepository {
  final FirebaseFirestore _firestore;
  GoalRepository(this._firestore);

  /// 🔁 リアルタイムでゴール一覧を取得
  Stream<List<Goal>> streamGoalsForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
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
  Future<void> addGoal(String userId, Goal goal) async {
    final data = goalToFirestoreData(goal);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goal.id)
        .set(data);
  }

  /// ❌ ゴールを削除
  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  /// 🔽 一括取得（リアルタイムではない）
  Future<List<Goal>> fetchGoals(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();

    return snapshot.docs
        .map((doc) => goalFromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// 🛠 ゴールを更新
  Future<void> updateGoal(String userId, Goal goal) async {
    final data = goalToFirestoreData(goal);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goal.id)
        .update(data);
  }
}

