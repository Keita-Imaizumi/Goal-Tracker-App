import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/auth_service.dart';



class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
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

            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;
                try {
                  await AuthService().registerWithEmailAndPassword(context, ref, email, password);
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('エラー'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('閉じる'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('新規登録'),
            ),
            const SizedBox(height: 8),

          ],
        ),
      ),
    );
  }
}
