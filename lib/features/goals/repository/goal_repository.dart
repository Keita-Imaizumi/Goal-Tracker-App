import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/goal/goal.dart';

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
}

