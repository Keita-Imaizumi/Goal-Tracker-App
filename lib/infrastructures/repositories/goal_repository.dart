import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/utils/goal_mapper.dart';
import '../../domains/entities/goal/goal.dart';
import '../../domains/Irepositories/goal_repository.dart';

part 'goal_repository.g.dart';
@riverpod
GoalRepository goalRepository(Ref ref) {
  return GoalRepository(FirebaseFirestore.instance);
}

class GoalRepository implements IGoalRepository{
  final FirebaseFirestore _firestore;
  GoalRepository(this._firestore);

  /// 🔁 リアルタイムでゴール一覧を取得
  @override
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
  @override
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
  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  /// 🔽 一括取得（リアルタイムではない）
  @override
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
  @override
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

