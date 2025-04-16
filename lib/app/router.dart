
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_tracker/features/auth/screens/login_screen.dart';
import 'package:goal_tracker/features/goals/screens/dashboard_screen.dart';

import '../features/splash/splash_screen.dart';


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
        GoRoute(path: '/login', builder: (context, state) => LoginScreen())
        // GoRoute(
        //     path: '/redirect',
        //     redirect: (context, state) async{
        //       if(await checkLoggedIn()){
        //         return '/home';
        //       }
        //       else {
        //         return '/login';
        //       }
        //     }
        // ),
        // GoRoute(
        //   path: '/detail/:$id',
        //   builder: (context, state) => DetailsScreen(),
        // ),
      ],
  );// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}