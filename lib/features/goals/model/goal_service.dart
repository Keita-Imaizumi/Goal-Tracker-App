import 'package:cloud_firestore/cloud_firestore.dart';

import 'goal.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addGoal(String uid, Goal goal) async {
    final data = {
      'title': goal.title,
      'status': goal.status,
      'deadline': goal.deadline != null
          ? Timestamp.fromDate(goal.deadline!)
          : null,
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
}