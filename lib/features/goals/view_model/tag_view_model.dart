import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goal_tracker/features/goals/model/tag/tag.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'tag_view_model.g.dart';

@riverpod
class TagViewModel extends _$TagViewModel {
  @override
  List<Tag> build() => [];

  void addTag(String name) {
    final newTag = Tag(id: const Uuid().v4(), name: name);
    state = [...state, newTag];
  }

  void removeTag(String id) {
    state = state.where((tag) => tag.id != id).toList();
  }
}