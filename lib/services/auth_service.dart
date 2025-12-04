import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Google sign-in implementation (core)
  Future<User?> _googleSignInCore() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      // bubble up Firebase auth errors with a clear message
      throw Exception('Google sign-in failed: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Keep existing method name for backward compatibility
  Future<User?> signUpWithGoogle() async {
    return await _googleSignInCore();
  }

  /// New method requested by signin.dart — aliases to same core logic
  Future<User?> signInWithGoogle() async {
    return await _googleSignInCore();
  }

  Future<void> createOrUpdateUserDoc({
    required User user,
    String? username,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final now = FieldValue.serverTimestamp();

    final snap = await docRef.get();
    if (snap.exists) {
      // only update mutable fields and updatedAt
      await docRef.update({
        'email': user.email,
        'username': username ?? user.displayName ?? '',
        'updatedAt': now,
      });
    } else {
      // create with createdAt + updatedAt
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'username': username ?? user.displayName ?? '',
        'createdAt': now,
        'updatedAt': now,
      });
    }
  }

  Future<void> signOut() async => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
