import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_session_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/user_id.dart';
import 'auth_session_providers.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, AuthSessionEntity?>(
      LoginController.new,
    );

class LoginController extends AsyncNotifier<AuthSessionEntity?> {
  @override
  Future<AuthSessionEntity?> build() async {
    return null;
  }

  Future<void> login({required String userId, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(loginUseCaseProvider);
      return useCase(
        userId: UserId(userId.trim()),
        password: Password(password.trim()),
      );
    });
  }
}
