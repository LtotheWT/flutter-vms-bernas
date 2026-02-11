import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class GetPersistedSessionUseCase {
  const GetPersistedSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSessionEntity?> call() {
    return _repository.getPersistedSession();
  }
}
