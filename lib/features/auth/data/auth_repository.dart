import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_placeholders.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref: ref);
});

class AuthRepository {
  const AuthRepository({required this.ref});

  final Ref ref;

  Future<AppUser> signInWithEmail({required String email, required String password}) async {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    if (firebaseAuth == null) {
      return AppUser(id: 'local-user', email: email, displayName: 'Portfolio Designer');
    }

    final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    return AppUser(
      id: user?.uid ?? 'unknown',
      email: user?.email ?? email,
      displayName: user?.displayName ?? 'Portique Member',
    );
  }

  Future<void> signOut() async {
    await ref.read(firebaseAuthProvider)?.signOut();
  }
}
