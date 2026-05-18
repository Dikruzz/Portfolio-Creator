import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/app_user.dart';

final class LocalAuthSessionStore {
  const LocalAuthSessionStore();

  static const _idKey = 'portique.auth.user.id';
  static const _emailKey = 'portique.auth.user.email';
  static const _displayNameKey = 'portique.auth.user.displayName';
  static const _providerKey = 'portique.auth.user.provider';
  static const _photoUrlKey = 'portique.auth.user.photoUrl';

  Future<AppUser?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final id = preferences.getString(_idKey);
    final displayName = preferences.getString(_displayNameKey);
    final providerName = preferences.getString(_providerKey);

    if (id == null || displayName == null || providerName == null) {
      return null;
    }

    return AppUser(
      id: id,
      email: preferences.getString(_emailKey),
      displayName: displayName,
      provider: AuthProviderType.values.firstWhere(
        (provider) => provider.name == providerName,
        orElse: () => AuthProviderType.guest,
      ),
      photoUrl: preferences.getString(_photoUrlKey),
    );
  }

  Future<void> write(AppUser user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_idKey, user.id);
    await preferences.setString(_displayNameKey, user.displayName);
    await preferences.setString(_providerKey, user.provider.name);

    if (user.email == null) {
      await preferences.remove(_emailKey);
    } else {
      await preferences.setString(_emailKey, user.email!);
    }

    if (user.photoUrl == null) {
      await preferences.remove(_photoUrlKey);
    } else {
      await preferences.setString(_photoUrlKey, user.photoUrl!);
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_idKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_displayNameKey);
    await preferences.remove(_providerKey);
    await preferences.remove(_photoUrlKey);
  }
}
