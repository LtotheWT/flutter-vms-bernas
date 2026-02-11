import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/auth_session_entity.dart';
import 'package:vms_bernas/domain/repositories/auth_repository.dart';
import 'package:vms_bernas/domain/usecases/login_usecase.dart';
import 'package:vms_bernas/domain/value_objects/password.dart';
import 'package:vms_bernas/domain/value_objects/user_id.dart';

class _FakeAuthRepository implements AuthRepository {
  UserId? capturedUserId;
  Password? capturedPassword;

  @override
  Future<AuthSessionEntity> login({
    required UserId userId,
    required Password password,
  }) async {
    capturedUserId = userId;
    capturedPassword = password;

    return const AuthSessionEntity(
      username: 'Ryan',
      fullname: 'Ryan',
      accessToken: 'token',
    );
  }

  @override
  Future<AuthSessionEntity?> getPersistedSession() async {
    return null;
  }

  @override
  Future<void> saveSession(AuthSessionEntity session) async {}
}

void main() {
  test('returns session and passes value objects to repository', () async {
    final repository = _FakeAuthRepository();
    final useCase = LoginUseCase(repository);

    final result = await useCase(
      userId: UserId('ryan'),
      password: Password('abc123'),
    );

    expect(result.username, 'Ryan');
    expect(result.accessToken, 'token');
    expect(repository.capturedUserId?.value, 'ryan');
    expect(repository.capturedPassword?.value, 'abc123');
  });
}
