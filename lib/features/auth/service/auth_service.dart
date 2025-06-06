import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';


import '../provider/auth_provider.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

class AuthService {
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
  final logger = Logger();

  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          logger.d('このメールアドレスは既に使用されています。');
          break;
        case 'invalid-email':
          logger.d('メールアドレスの形式が正しくありません。');
          break;
        case 'weak-password':
          logger.d('パスワードが弱すぎます。');
          break;
        default:
          logger.d('新規登録時に予期しないエラー: ${e.code}');
      }
      return null;
    } catch (e) {
      logger.d('その他のエラー: $e');
      return null;
    }
  }

  Future<void> registerWithEmailAndPassword(
      BuildContext context, WidgetRef ref, String email, String password) async {
    // バリデーション（例: 空チェック）
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
      );
      return;
    }

    // 登録処理
    final user = await signUpWithEmail(email, password);
    if (user != null) {
      ref.read(userStateProvider.notifier).setUser(user);
      context.go('/dashboard/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登録に失敗しました')),
      );
    }
  }

  Future<bool> checkIfEmailExists(String email) async {
    try {
      final methods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      logger.d('メール確認エラー: $e');
      return false;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      logger.d('ログインエラー: $e');
      return null;
    }
  }

  /// サインアウト（Google含む）
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // ignore: GoogleSignInが使用されていない場合
    }
    await _auth.signOut();
  }

  /// 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;
}
