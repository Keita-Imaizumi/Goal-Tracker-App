import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view/login_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/goals/view/dashboard_screen.dart';
import '../features/splash/view/splash_screen.dart';


class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
      initialLocation: "/splash",
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => DashboardScreen(),
        ),
        GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => SignupScreen()),
      ],
  );// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}