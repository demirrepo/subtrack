// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await createOrUpdateUserDoc(user: user);
    }
    return user;
  }

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await createOrUpdateUserDoc(
        user: user,
      ); // ensures fields exist after sign-in
    }
    return user;
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
      final user = userCred.user;
      if (user != null) {
        await createOrUpdateUserDoc(user: user, username: user.displayName);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Google sign-in failed: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<User?> signUpWithGoogle() async => await _googleSignInCore();
  Future<User?> signInWithGoogle() async => await _googleSignInCore();

  /// Ensure user doc exists and has subscriptionIds array.
  Future<void> createOrUpdateUserDoc({
    required User user,
    String? username,
  }) async {
    final docRef = _db.collection('users').doc(user.uid);
    final now = FieldValue.serverTimestamp();

    final snap = await docRef.get();
    if (snap.exists) {
      final data = snap.data()!;
      final updates = <String, Object?>{
        'email': user.email,
        'username': username ?? user.displayName ?? '',
        'updatedAt': now,
      };

      // If subscriptionIds missing, set it to empty array (don't overwrite existing)
      if (!data.containsKey('subscriptionIds')) {
        updates['subscriptionIds'] = <String>[];
      }

      await docRef.update(updates);
    } else {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'username': username ?? user.displayName ?? '',
        'subscriptionIds': <String>[],
        'createdAt': now,
        'updatedAt': now,
      });
    }
  }

  /// Helpers to maintain the user subscription index individually (optional)
  Future<void> addSubscriptionId({
    required String userId,
    required String subscriptionId,
  }) {
    final userDoc = _db.collection('users').doc(userId);
    return userDoc.update({
      'subscriptionIds': FieldValue.arrayUnion([subscriptionId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeSubscriptionId({
    required String userId,
    required String subscriptionId,
  }) {
    final userDoc = _db.collection('users').doc(userId);
    return userDoc.update({
      'subscriptionIds': FieldValue.arrayRemove([subscriptionId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async => _auth.signOut();
  User? get currentUser => _auth.currentUser;
}
