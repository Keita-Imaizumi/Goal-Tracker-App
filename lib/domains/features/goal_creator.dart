import '../../../domains/entities/goal/goal.dart';
import '../../../domains/entities/tag/tag.dart';

import 'package:uuid/uuid.dart';

//Goalを作成するためのクラス｀
class GoalCreator {
  Goal createGoal(
    String title, {
    String? detail,
    DateTime? deadline,
    List<Tag> tags = const [],
  }) {
    final id = const Uuid().v4();
    return Goal(
      id: id,
      title: title,
      detail: detail,
      deadline: deadline,
      done: false,
      tags: tags,
      tasks: [],
    );
  }
}