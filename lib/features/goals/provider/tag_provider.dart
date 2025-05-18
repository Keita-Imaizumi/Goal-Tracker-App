import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repository/tag_repository.dart';
part 'tag_provider.g.dart';
@riverpod
TagRepository tagService(Ref ref) {
  return TagRepository();
}
