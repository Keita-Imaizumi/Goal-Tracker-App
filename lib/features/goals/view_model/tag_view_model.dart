import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/tag/tag.dart';
import '../provider/tag_provider.dart';

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
      await ref.read(tagServiceProvider).createTag(uid, name);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  Future<List<Tag>> fetchTags(String uid) async {
    state = const AsyncLoading(); // オプション: ロード状態をUIに示したい場合
    try {
      final tags = await ref.read(tagServiceProvider).fetchTags(uid);
      state = const AsyncData(null); // 成功しても特にデータは持たない設計
      return tags;
    } catch (e, st) {
      state = AsyncError(e, st);
      return [];
    }
  }
}

