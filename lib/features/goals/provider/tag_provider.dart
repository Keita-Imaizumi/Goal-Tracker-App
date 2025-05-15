import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../service/tag_service.dart';
part 'tag_provider.g.dart';
@riverpod
TagService tagService(TagServiceRef ref) {
  return TagService();
}
