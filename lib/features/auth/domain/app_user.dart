enum AuthProviderType { email, google, guest }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.provider,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String displayName;
  final AuthProviderType provider;
  final String? photoUrl;

  bool get isGuest => provider == AuthProviderType.guest;
}
