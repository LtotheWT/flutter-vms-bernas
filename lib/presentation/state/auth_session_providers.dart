import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/config/api_config.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/network/dio_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_persisted_session_usecase.dart';
import '../../domain/usecases/save_session_usecase.dart';

enum AuthRouteState { unknown, authenticated, unauthenticated }

class AuthRouteNotifier extends ChangeNotifier {
  AuthRouteState _state = AuthRouteState.unknown;

  AuthRouteState get state => _state;

  bool get isAuthenticated => _state == AuthRouteState.authenticated;

  bool get isUnauthenticated => _state == AuthRouteState.unauthenticated;

  void setAuthenticated() {
    if (_state == AuthRouteState.authenticated) {
      return;
    }
    _state = AuthRouteState.authenticated;
    notifyListeners();
  }

  void setUnauthenticated() {
    if (_state == AuthRouteState.unauthenticated) {
      return;
    }
    _state = AuthRouteState.unauthenticated;
    notifyListeners();
  }
}

class AuthSessionController {
  AuthSessionController(this._ref);

  final Ref _ref;
  Future<void>? _logoutFuture;

  void markAuthenticated() {
    _ref.read(authRouteNotifierProvider).setAuthenticated();
  }

  void markUnauthenticated() {
    _ref.read(authRouteNotifierProvider).setUnauthenticated();
  }

  Future<void> logoutDueToUnauthorized() {
    if (_logoutFuture != null) {
      return _logoutFuture!;
    }
    _logoutFuture = _performUnauthorizedLogout();
    return _logoutFuture!;
  }

  Future<void> _performUnauthorizedLogout() async {
    try {
      await _ref.read(authLocalDataSourceProvider).clearSession();
      markUnauthenticated();
    } finally {
      _logoutFuture = null;
    }
  }
}

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.fromEnvironment();
});

final authRouteNotifierProvider = Provider<AuthRouteNotifier>((ref) {
  final notifier = AuthRouteNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

final authSessionControllerProvider = Provider<AuthSessionController>((ref) {
  return AuthSessionController(ref);
});

final dioClientProvider = Provider<Dio>((ref) {
  final config = ref.read(apiConfigProvider);
  final sessionController = ref.read(authSessionControllerProvider);
  return createDio(
    config,
    onUnauthorized: () => sessionController.logoutDueToUnauthorized(),
  );
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.read(dioClientProvider);
  final apiConfig = ref.read(apiConfigProvider);
  return AuthRemoteDataSource(dio: dio, apiConfig: apiConfig);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.read(secureStorageProvider);
  return AuthLocalDataSource(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource);
});

final getPersistedSessionUseCaseProvider = Provider<GetPersistedSessionUseCase>(
  (ref) {
    final repository = ref.read(authRepositoryProvider);
    return GetPersistedSessionUseCase(repository);
  },
);

final saveSessionUseCaseProvider = Provider<SaveSessionUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SaveSessionUseCase(repository);
});
