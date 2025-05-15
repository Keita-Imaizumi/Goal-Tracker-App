import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repository/tag_service.dart';
part 'tag_provider.g.dart';
@riverpod
TagService tagService(Ref ref) {
  return TagService();
}
