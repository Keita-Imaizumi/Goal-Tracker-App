// lib/auth/providers/auth_providers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<User?>((ref) => null); // ログイン済みユーザー保持

