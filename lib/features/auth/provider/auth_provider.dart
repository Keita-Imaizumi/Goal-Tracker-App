import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class UserState extends _$UserState {
  @override
  User? build() => null;

  void setUser(User? user) => state = user;
}