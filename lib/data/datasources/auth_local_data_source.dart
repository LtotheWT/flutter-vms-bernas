import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session_dto.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_access_token';
  static const String _usernameKey = 'auth_username';
  static const String _fullnameKey = 'auth_fullname';
  static const String _entityKey = 'auth_entity';
  static const String _defaultSiteKey = 'auth_default_site';
  static const String _defaultGateKey = 'auth_default_gate';

  Future<void> saveSession(AuthSessionDto session) async {
    await _storage.write(key: _tokenKey, value: session.accessToken);
    await _storage.write(key: _usernameKey, value: session.username);
    await _storage.write(key: _fullnameKey, value: session.fullname);
    await _storage.write(key: _entityKey, value: session.entity);
    await _storage.write(key: _defaultSiteKey, value: session.defaultSite);
    await _storage.write(key: _defaultGateKey, value: session.defaultGate);
  }

  Future<AuthSessionDto?> getSession() async {
    final accessToken = await _storage.read(key: _tokenKey);
    if (accessToken == null || accessToken.trim().isEmpty) {
      return null;
    }

    final username = await _storage.read(key: _usernameKey) ?? '';
    final fullname = await _storage.read(key: _fullnameKey) ?? '';
    final entity = await _storage.read(key: _entityKey) ?? '';
    final defaultSite = await _storage.read(key: _defaultSiteKey) ?? '';
    final defaultGate = await _storage.read(key: _defaultGateKey) ?? '';

    return AuthSessionDto(
      username: username,
      fullname: fullname,
      entity: entity,
      accessToken: accessToken,
      defaultSite: defaultSite,
      defaultGate: defaultGate,
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _fullnameKey);
    await _storage.delete(key: _entityKey);
    await _storage.delete(key: _defaultSiteKey);
    await _storage.delete(key: _defaultGateKey);
  }
}
