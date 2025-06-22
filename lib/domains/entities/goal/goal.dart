import 'package:freezed_annotation/freezed_annotation.dart';

import '../tag/tag.dart';
import '../task/task.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String title,
    String? detail,
    DateTime? deadline, // ← ここはDateTimeのみ
    @Default(false) bool done,
    @Default([]) List<Tag> tags,
    @Default([]) List<Task> tasks,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
