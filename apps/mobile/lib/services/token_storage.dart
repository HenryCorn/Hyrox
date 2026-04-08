import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT access token in the device's secure keychain/keystore.
class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccessToken = 'hyrox_access_token';
  static const _keyUserId = 'hyrox_user_id';
  static const _keyDisplayName = 'hyrox_display_name';

  Future<void> saveSession({
    required String accessToken,
    required String userId,
    required String displayName,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyDisplayName, value: displayName),
    ]);
  }

  Future<StoredSession?> loadSession() async {
    final results = await Future.wait([
      _storage.read(key: _keyAccessToken),
      _storage.read(key: _keyUserId),
      _storage.read(key: _keyDisplayName),
    ]);
    final token = results[0];
    final userId = results[1];
    final name = results[2];
    if (token == null || userId == null) return null;
    return StoredSession(
      accessToken: token,
      userId: userId,
      displayName: name ?? 'Athlete',
    );
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyDisplayName),
    ]);
  }
}

class StoredSession {
  final String accessToken;
  final String userId;
  final String displayName;
  const StoredSession({
    required this.accessToken,
    required this.userId,
    required this.displayName,
  });
}
