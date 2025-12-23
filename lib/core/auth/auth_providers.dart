import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProviders {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    final user = userCredential.user;
    if (user != null) {
      await _saveUserIfNotExists(user, 'google.com');
    }

    return user;
  }

  static Future<User?> signInWithFacebook() async {
    try {
      final facebookProvider = FacebookAuthProvider();

      final userCredential =
          await FirebaseAuth.instance.signInWithPopup(facebookProvider);

      final user = userCredential.user;

      if (user != null) {
        await _saveUserIfNotExists(user, 'facebook.com');
      }

      return user;
    } catch (e) {
      print('Error Facebook login: $e');
      return null;
    }
  }

  static Future<void> _saveUserIfNotExists(User? user, String provider) async {
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photo': user.photoURL ?? '',
        'role': 'user',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'provider': provider,
      });
    }
  }
}
