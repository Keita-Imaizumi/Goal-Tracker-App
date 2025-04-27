import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../tag/tag.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String title,
    required String status,
    String? detail,
    @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
    DateTime? deadline,
    @Default(false) bool done,
    @Default([]) List<Tag> tags,
    @Default([]) List<Task> tasks,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    DateTime? deadline,
    @Default(false) bool done,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  throw ArgumentError('Unsupported timestamp format: $value');
}

dynamic _toTimestamp(DateTime? dateTime) {
  return dateTime;
}

Goal goalFromFirestore(String id, Map<String, dynamic> data) {
  return Goal.fromJson({...data, 'id': id});
}

extension GoalFirestore on Goal {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}


