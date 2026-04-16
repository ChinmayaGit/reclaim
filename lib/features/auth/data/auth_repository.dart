import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ─── Email / Password ──────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _createUserDocument(cred.user!);
    return cred;
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    if (cred.additionalUserInfo?.isNewUser == true) {
      await _createUserDocument(cred.user!);
    }
    return cred;
  }

  // ─── Sign out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // ─── Password reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ─── User document ────────────────────────────────────────────────────────

  Future<void> _createUserDocument(User user) async {
    final doc = _firestore.collection(AppConstants.colUsers).doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      final model = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        role: AppConstants.roleFree,
      );
      await doc.set(model.toJson());
    }
  }

  Future<void> updateUserProfile(UserModel model) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(model.uid)
        .update(model.toJson());
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .update({'fcmToken': token});
  }

  Future<void> completeOnboarding(String uid, {
    required List<String> recoveryTypes,
    required String recoverySubType,
    required DateTime sobrietyDate,
  }) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .update({
      'recoveryTypes': recoveryTypes,
      'recoverySubType': recoverySubType,
      'sobrietyDate': Timestamp.fromDate(sobrietyDate),
      'onboardingComplete': true,
    });
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});
