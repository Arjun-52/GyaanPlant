import 'package:firebase_auth/firebase_auth.dart';

class GoogleUser {
  final String name;
  final String email;
  final String uid;
  final String? photoUrl;

  GoogleUser({required this.name, required this.email, required this.uid, this.photoUrl});

  factory GoogleUser.fromFirebaseUser(User user) {
    return GoogleUser(
      name: user.displayName ?? '',
      email: user.email ?? '',
      uid: user.uid,
      photoUrl: user.photoURL,
    );
  }
}
