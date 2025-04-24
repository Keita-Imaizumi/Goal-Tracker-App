import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_provider.g.dart';

@riverpod
class UserState extends _$UserState {
  @override
  User? build() => null;

  void setUser(User? user) => state = user;
}
