import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  GoalViewModel(this.ref) : super(const AsyncData(null));

//
}
