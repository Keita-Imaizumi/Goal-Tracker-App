import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/login_page/login_screen.dart';
import '../presentation/pages/signup_page/signup_screen.dart';
import '../presentation/pages/goal_list_page/dashboard_screen.dart';
import '../presentation/pages/splash_page/splash_screen.dart';


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