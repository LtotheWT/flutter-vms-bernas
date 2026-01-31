import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/user_id.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> login({
    required UserId userId,
    required Password password,
  }) {
    return _remoteDataSource.login(
      userId: userId.value,
      password: password.value,
    );
  }
}
