import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/user_id.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_session_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthSessionEntity> login({
    required UserId userId,
    required Password password,
  }) async {
    final session = await _remoteDataSource.login(
      userId: userId.value,
      password: password.value,
    );
    await _localDataSource.saveSession(session);
    return session.toEntity();
  }

  @override
  Future<AuthSessionEntity?> getPersistedSession() async {
    final session = await _localDataSource.getSession();
    return session?.toEntity();
  }

  @override
  Future<void> saveSession(AuthSessionEntity session) {
    return _localDataSource.saveSession(AuthSessionDto.fromEntity(session));
  }
}
