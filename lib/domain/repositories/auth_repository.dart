import '../value_objects/password.dart';
import '../value_objects/user_id.dart';

abstract class AuthRepository {
  Future<void> login({
    required UserId userId,
    required Password password,
  });
}
