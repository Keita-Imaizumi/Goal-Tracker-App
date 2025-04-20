import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../goals/data/goals.dart';
import '../../goals/services/goal_repository.dart';
import '../../goals/services/goal_service.dart';
import '../services/auth_service.dart';

final userProvider = StateProvider<User?>((ref) => null); // ログイン済みユーザー保持

final goalRepositoryProvider = Provider((ref) => GoalRepository());
final goalListProvider = StateProvider<List<Goal>>((ref) => []);

final userGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(goalRepositoryProvider).streamGoalsForUser(user.uid);
});

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // FirebaseAuthインスタンスを取得
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // GoogleSignInインスタンスを取得
  // scopeにはAPIを通して操作できるユーザのリソースを指定する、以下のページを参照
  // https://developers.google.com/identity/protocols/oauth2/scopes?hl=ja#fcm
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    // 例えば、Google Calendarの情報を操作するには、ここに範囲を記載する
    // https://www.googleapis.com/auth/calendar.readonly,
    // https://www.googleapis.com/auth/calendar.events,
  ]);

  // ログインしたユーザー情報を保持する変数
  User? _user;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = emailController.text;
    final password = passwordController.text;
    // TODO: ログイン処理を追加
    print('ログイン: $email / $password');
  }

  void _onResetPassword() {
    // TODO: パスワード再設定処理を追加
    print('パスワード再設定へ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // メールアドレス
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // パスワード
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'パスワード',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ログインボタン
            ElevatedButton(
              onPressed: _onLoginPressed,
              child: const Text('ログイン'),
            ),
            const SizedBox(height: 8),

            // Googleログイン
            OutlinedButton.icon(
              onPressed: () async {
                final user = await AuthService().signInWithGoogle();
                if (user != null) {
                  ref.read(userProvider.notifier).state = user;

                  final goals = await GoalService().fetchGoals(user.uid);
                  ref.read(goalListProvider.notifier).state = goals;
                  context.go('/dashboard/');
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Googleアカウントでログイン'),
            ),
            const SizedBox(height: 8),

            // パスワード再設定
            TextButton(
              onPressed: _onResetPassword,
              child: const Text('パスワードを忘れた場合はこちら'),
            ),
            TextButton(
              onPressed: () {
                context.go('/register');
              },
              child: const Text('アカウントをお持ちでない方はこちらから新規登録'),
            ),
          ],
        ),
      ),
    );
  }
}
