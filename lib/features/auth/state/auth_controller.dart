import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_failure.dart';

enum AuthAction { email, google, guest, signOut }

class AuthState {
  const AuthState({
    this.user,
    this.isRestoring = true,
    this.loadingAction,
    this.errorMessage,
  });

  final AppUser? user;
  final bool isRestoring;
  final AuthAction? loadingAction;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
  bool get isBusy => isRestoring || loadingAction != null;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? isRestoring,
    AuthAction? loadingAction,
    bool clearLoadingAction = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isRestoring: isRestoring ?? this.isRestoring,
      loadingAction: clearLoadingAction ? null : loadingAction ?? this.loadingAction,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState()) {
    restoreSession();
  }

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    state = state.copyWith(isRestoring: true, clearError: true);
    try {
      final user = await _repository.restoreSession();
      if (!mounted) return;
      state = AuthState(user: user, isRestoring: false);
    } catch (error) {
      if (!mounted) return;
      state = AuthState(isRestoring: false, errorMessage: _messageFor(error));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _authenticate(
      AuthAction.email,
      () => _repository.signInWithEmail(email: email.trim(), password: password),
    );
  }

  Future<void> signInWithGoogle() async {
    await _authenticate(AuthAction.google, _repository.signInWithGoogle);
  }

  Future<void> continueAsGuest() async {
    await _authenticate(AuthAction.guest, _repository.continueAsGuest);
  }

  Future<void> signOut() async {
    state = state.copyWith(loadingAction: AuthAction.signOut, clearError: true);
    try {
      await _repository.signOut();
      if (!mounted) return;
      state = const AuthState(isRestoring: false);
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        clearLoadingAction: true,
        errorMessage: _messageFor(error),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _authenticate(
    AuthAction action,
    Future<AppUser> Function() callback,
  ) async {
    state = state.copyWith(loadingAction: action, clearError: true);
    try {
      final user = await callback();
      if (!mounted) return;
      state = AuthState(user: user, isRestoring: false);
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        clearLoadingAction: true,
        errorMessage: _messageFor(error),
      );
    }
  }

  String _messageFor(Object error) {
    if (error is AuthFailure) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
