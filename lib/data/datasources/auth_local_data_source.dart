import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session_dto.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_access_token';
  static const String _usernameKey = 'auth_username';
  static const String _fullnameKey = 'auth_fullname';

  Future<void> saveSession(AuthSessionDto session) async {
    await _storage.write(key: _tokenKey, value: session.accessToken);
    await _storage.write(key: _usernameKey, value: session.username);
    await _storage.write(key: _fullnameKey, value: session.fullname);
  }

  Future<AuthSessionDto?> getSession() async {
    final accessToken = await _storage.read(key: _tokenKey);
    if (accessToken == null || accessToken.trim().isEmpty) {
      return null;
    }

    final username = await _storage.read(key: _usernameKey) ?? '';
    final fullname = await _storage.read(key: _fullnameKey) ?? '';

    return AuthSessionDto(
      username: username,
      fullname: fullname,
      accessToken: accessToken,
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _fullnameKey);
  }
}
