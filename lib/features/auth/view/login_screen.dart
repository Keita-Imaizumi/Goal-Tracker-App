// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_model/login_view_model.dart';
import '../provider/login_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(loginViewModelProvider.notifier);
    final state = ref.watch(loginViewModelProvider);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
            Consumer(
              builder: (context, ref, _) {
                final visible = ref.watch(isPasswordVisibleProvider);
                return TextField(
                  controller: passwordController,
                  obscureText: !visible,
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        visible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        ref.read(isPasswordVisibleProvider.notifier).toggle();
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // ログインボタン
            ElevatedButton(
              onPressed: () {
                viewModel.loginWithEmail(
                  emailController.text,
                  passwordController.text,
                  context,
                );
              },
              child: state is AsyncLoading
                  ? const CircularProgressIndicator()
                  : const Text('ログイン'),
            ),
            const SizedBox(height: 8),

            // Googleログイン
            OutlinedButton.icon(
              onPressed: () => viewModel.loginWithGoogle(context),
              icon: const Icon(Icons.login),
              label: const Text('Googleアカウントでログイン'),
            ),
            const SizedBox(height: 8),

            // パスワード再設定
            // TextButton(
            //   onPressed: () {
            //     // TODO: パスワード再設定
            //   },
            //   child: const Text('パスワードを忘れた場合はこちら'),
            // ),
            TextButton(
              onPressed: () {
                context.push('/register');
              },
              child: const Text('アカウントをお持ちでない方はこちらから新規登録'),
            ),
          ],
        ),
      ),
    );
  }
}
