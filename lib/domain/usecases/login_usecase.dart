import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/password.dart';
import '../value_objects/user_id.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSessionEntity> call({
    required UserId userId,
    required Password password,
  }) {
    return _repository.login(userId: userId, password: password);
  }
}
