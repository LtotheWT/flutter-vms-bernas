import '../entities/auth_session_entity.dart';
import '../value_objects/password.dart';
import '../value_objects/user_id.dart';

abstract class AuthRepository {
  Future<AuthSessionEntity> login({
    required UserId userId,
    required Password password,
  });

  Future<AuthSessionEntity?> getPersistedSession();

  Future<void> saveSession(AuthSessionEntity session);
}
