import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/auth/google_user.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Initiates Google Sign‑In flow.
  /// Returns a [GoogleUser] on success or throws an exception on failure.
  Future<GoogleUser> signIn() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign‑in
        throw Exception('Sign‑in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null');
      }

      return GoogleUser.fromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      // Propagate Firebase specific errors
      throw Exception('Firebase auth error: ${e.message}');
    } catch (e) {
      // Generic fallback
      rethrow;
    }
  }

  /// Sign out from both Google and Firebase.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
