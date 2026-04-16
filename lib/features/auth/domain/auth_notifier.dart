import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<bool> signInWithEmail(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await _repo.signInWithEmail(email, password);
      state = const AuthState();
      return true;
    } catch (e) {
      state = AuthState(errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await _repo.registerWithEmail(email, password);
      state = const AuthState();
      return true;
    } catch (e) {
      state = AuthState(errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      await _repo.signInWithGoogle();
      state = const AuthState();
      return true;
    } catch (e) {
      state = AuthState(errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AuthState(isLoading: true);
    try {
      await _repo.sendPasswordReset(email);
      state = const AuthState();
      return true;
    } catch (e) {
      state = AuthState(errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<void> completeOnboarding(String uid, {
    required List<String> recoveryTypes,
    required String recoverySubType,
    required DateTime sobrietyDate,
  }) async {
    await _repo.completeOnboarding(
      uid,
      recoveryTypes: recoveryTypes,
      recoverySubType: recoverySubType,
      sobrietyDate: sobrietyDate,
    );
  }

  void clearError() => state = const AuthState();

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('user-not-found') || msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    } else if (msg.contains('email-already-in-use')) {
      return 'This email is already registered.';
    } else if (msg.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    } else if (msg.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (msg.contains('network')) {
      return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
