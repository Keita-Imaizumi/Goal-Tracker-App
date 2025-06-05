import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_provider.g.dart';

@riverpod
class IsPasswordVisible extends _$IsPasswordVisible {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
