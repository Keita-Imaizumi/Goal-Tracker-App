import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/tag/tag.dart';
import '../repository/tag_repository.dart';

part 'tag_view_model.g.dart';

@riverpod
class TagViewModel extends _$TagViewModel {
  @override
  AsyncValue<void> build() {
    // 初期値を返す（初期ロードなしなら null）
    return const AsyncData(null);
  }

  Future<void> createTag(String uid, String name) async {
    // 入力検証（タイトルが空）
    if (name.isEmpty) {
      state = AsyncError('タイトルは必須です', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      await ref.read(tagRepositoryProvider).createTag(uid, name);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> removeTag(String userId, String tagId) async {
    try{
      await ref.read(tagRepositoryProvider).removeTag(userId, tagId);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<List<Tag>> fetchTags(String uid) async {
    state = const AsyncLoading();
    try {
      final tags = await ref.read(tagRepositoryProvider).fetchTags(uid);
      state = const AsyncData(null);
      return tags;
    } catch (e, st) {
      state = AsyncError(e, st);
      return [];
    }
  }
}

