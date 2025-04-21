import 'package:freezed_annotation/freezed_annotation.dart';

part 'goals.freezed.dart';
part 'goals.g.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String title,
    required String status,
    String? detail,
    DateTime? deadline,
    @Default(false) bool done,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
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


