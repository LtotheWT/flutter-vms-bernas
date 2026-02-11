import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'network/remote_parsers.dart';
import '../models/auth_session_dto.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required Dio dio, required ApiConfig apiConfig})
    : _dio = dio,
      _apiConfig = apiConfig;

  final Dio _dio;
  final ApiConfig _apiConfig;

  Future<AuthSessionDto> login({
    required String userId,
    required String password,
  }) async {
    final requestDto = LoginRequestDto(
      ccn: _apiConfig.ccn,
      userName: userId,
      password: password,
    );

    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Auth/login',
        data: requestDto.toJson(),
      );

      final responseDto = LoginResponseDto.fromJson(
        parseJsonMap(response.data),
      );

      if (!responseDto.status) {
        throw AuthException(_resolveBackendMessage(responseDto.errorMessage));
      }

      final details = responseDto.details;
      if (details == null || details.accessToken.trim().isEmpty) {
        throw AuthException('Login failed. Please try again.');
      }

      return details;
    } on DioException catch (error) {
      final backendMessage = _extractBackendMessage(error.response?.data);
      if (backendMessage != null && backendMessage.isNotEmpty) {
        throw AuthException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw AuthException(
          'Unable to connect to server. Please check your connection.',
        );
      }

      throw AuthException('Login failed. Please try again.');
    }
  }

  String _resolveBackendMessage(String? message) {
    if (message == null || message.isEmpty) {
      return 'Login failed. Please try again.';
    }
    return message;
  }

  String? _extractBackendMessage(dynamic data) {
    try {
      final map = parseJsonMap(data);
      final responseDto = LoginResponseDto.fromJson(map);
      return responseDto.errorMessage;
    } catch (_) {
      return null;
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
