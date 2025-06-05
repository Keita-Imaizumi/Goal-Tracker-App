// Basic widget test to ensure the app builds without crashing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/app/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));
    await tester.pump(const Duration(seconds: 4)); // Allow splash timer to finish
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
