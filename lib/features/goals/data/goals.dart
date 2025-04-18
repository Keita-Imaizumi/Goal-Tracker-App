import 'package:cloud_firestore/cloud_firestore.dart';
class Goal {
  final String id;
  final String title;
  final String status;
  final DateTime? deadline;

  Goal({
    required this.id,
    required this.title,
    required this.status,
    this.deadline,
  });

  factory Goal.fromMap(String id, Map<String, dynamic> data) {
    return Goal(
      id: id,
      title: data['title'],
      status: data['status'],
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'deadline': deadline,
    };
  }
}

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Goal>> streamGoalsForUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Goal.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> addGoal(String uid, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .add(goal.toMap());
  }

// さらに update / delete も必要なら追加
}

