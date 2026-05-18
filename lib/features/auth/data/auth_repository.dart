import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase/firebase_placeholders.dart';
import '../domain/app_user.dart';
import '../domain/auth_failure.dart';
import 'local/local_auth_session_store.dart';

final localAuthSessionStoreProvider = Provider<LocalAuthSessionStore>((ref) {
  return const LocalAuthSessionStore();
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: const ['email', 'profile']);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    sessionStore: ref.watch(localAuthSessionStoreProvider),
  );
});

class AuthRepository {
  const AuthRepository({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.sessionStore,
  });

  final firebase.FirebaseAuth? firebaseAuth;
  final GoogleSignIn googleSignIn;
  final LocalAuthSessionStore sessionStore;

  Future<AppUser?> restoreSession() async {
    final auth = firebaseAuth;
    if (auth != null) {
      final currentUser = await auth.authStateChanges().first.timeout(
            const Duration(seconds: 2),
            onTimeout: () => auth.currentUser,
          );
      if (currentUser != null) {
        final user = _fromFirebaseUser(currentUser, _providerFor(currentUser));
        await sessionStore.write(user);
        return user;
      }
    }

    return sessionStore.read();
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _validateEmailCredentials(email: email, password: password);

    final auth = firebaseAuth;
    if (auth == null) {
      final user = AppUser(
        id: 'local-email-${email.hashCode}',
        email: email,
        displayName: _displayNameFromEmail(email) ?? 'Portique Member',
        provider: AuthProviderType.email,
      );
      await sessionStore.write(user);
      return user;
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _fromFirebaseUser(credential.user, AuthProviderType.email);
      await sessionStore.write(user);
      return user;
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  Future<AppUser> signInWithGoogle() async {
    final auth = firebaseAuth;
    if (auth == null) {
      final user = const AppUser(
        id: 'local-google-user',
        email: 'google.user@portique.app',
        displayName: 'Google Portfolio Pro',
        provider: AuthProviderType.google,
      );
      await sessionStore.write(user);
      return user;
    }

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await auth.signInWithCredential(credential);
      final user = _fromFirebaseUser(userCredential.user, AuthProviderType.google);
      await sessionStore.write(user);
      return user;
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  Future<AppUser> continueAsGuest() async {
    final auth = firebaseAuth;
    if (auth == null) {
      final user = AppUser(
        id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
        email: null,
        displayName: 'Guest Curator',
        provider: AuthProviderType.guest,
      );
      await sessionStore.write(user);
      return user;
    }

    try {
      final credential = await auth.signInAnonymously();
      final user = _fromFirebaseUser(credential.user, AuthProviderType.guest);
      await sessionStore.write(user);
      return user;
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(_firebaseMessage(error));
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      if (firebaseAuth != null) firebaseAuth!.signOut(),
      googleSignIn.signOut(),
      sessionStore.clear(),
    ]);
  }

  AppUser _fromFirebaseUser(firebase.User? user, AuthProviderType fallbackProvider) {
    if (user == null) {
      throw const AuthFailure('Authentication completed without a user profile.');
    }

    final provider = user.isAnonymous ? AuthProviderType.guest : fallbackProvider;
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName ?? _displayNameFromEmail(user.email) ?? 'Portique Member',
      provider: provider,
      photoUrl: user.photoURL,
    );
  }


  AuthProviderType _providerFor(firebase.User user) {
    if (user.isAnonymous) return AuthProviderType.guest;
    final providerId = user.providerData.isEmpty ? null : user.providerData.first.providerId;
    return switch (providerId) {
      'google.com' => AuthProviderType.google,
      _ => AuthProviderType.email,
    };
  }

  void _validateEmailCredentials({required String email, required String password}) {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw const AuthFailure('Enter a valid email address.');
    }
    if (password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters.');
    }
  }

  String? _displayNameFromEmail(String? email) {
    final name = email?.split('@').first.trim();
    if (name == null || name.isEmpty) return null;
    return name
        .split(RegExp('[-._]'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _firebaseMessage(firebase.FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No Portique account exists for that email.',
      'wrong-password' => 'The password does not match this account.',
      'invalid-credential' => 'The sign-in credentials are invalid or expired.',
      'network-request-failed' => 'Network error. Check your connection and try again.',
      'popup-closed-by-user' => 'Google sign-in was closed before it completed.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
}
