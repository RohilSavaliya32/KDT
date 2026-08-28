import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  Future<String?> signIn() async {
    try {
      // Previous selected account remove
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect().catchError((_) {});

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final firebaseToken = await userCredential.user?.getIdToken();

      print("FIREBASE TOKEN = $firebaseToken");

      return firebaseToken;
    } catch (e, s) {
      print("========== GOOGLE SIGN IN ==========");
      print(e);
      print(s);
      rethrow;
    }
  }
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect().catchError((_) {});
  }
}