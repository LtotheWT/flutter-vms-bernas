import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class SaveSessionUseCase {
  const SaveSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(AuthSessionEntity session) {
    return _repository.saveSession(session);
  }
}
