import 'package:dio/dio.dart';
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

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.fromEnvironment();
});

final dioClientProvider = Provider<Dio>((ref) {
  final config = ref.read(apiConfigProvider);
  return createDio(config);
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
