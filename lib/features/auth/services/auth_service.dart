import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
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
