import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../shared/constants/app_constants.dart';

// ─── Firebase instances ──────────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final storageProvider = Provider<FirebaseStorage>(
  (_) => FirebaseStorage.instance,
);

// ─── Auth state ──────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

// ─── User role from custom claims ────────────────────────────────────────────

final userRoleProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return AppConstants.roleGuest;
  final result = await user.getIdTokenResult(true);
  return result.claims?['role'] as String? ?? AppConstants.roleFree;
});

// ─── User profile from Firestore ─────────────────────────────────────────────

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection(AppConstants.colUsers)
      .doc(user.uid)
      .snapshots()
      .map((snap) {
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromJson(snap.data()!);
  });
});

// ─── Convenience getters ─────────────────────────────────────────────────────

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// All features are free — Reclaim is donation-supported, not subscription-gated.
// isPremiumProvider always returns true so no content is ever locked.
final isPremiumProvider = Provider<bool>((_) => true);

final isCounselorProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  return profile?.isCounselor ?? false;
});

final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  return profile?.isAdmin ?? false;
});
