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

