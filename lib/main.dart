import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebaseの初期化
  await Firebase.initializeApp();
  runApp(ProviderScope(
    child: MyApp(),
  ),);
}