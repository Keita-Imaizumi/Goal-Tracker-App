import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // フェードインアニメーション
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // 3秒後に遷移
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // ダークカラーで引き締め
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ロゴまたはアイコン
              Icon(Icons.check_circle_outline,
                  size: 80, color: Colors.tealAccent),

              const SizedBox(height: 20),

              // アプリ名 or キャッチコピー
              Text(
                'TaskMaster',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '目標に、まっすぐ。',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
