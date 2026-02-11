import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/auth_session_dto.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required Dio dio,
    required ApiConfig apiConfig,
  }) : _dio = dio,
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

      final responseDto = LoginResponseDto.fromJson(_asMap(response.data));

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

      if (_isConnectivityIssue(error)) {
        throw AuthException(
          'Unable to connect to server. Please check your connection.',
        );
      }

      throw AuthException('Login failed. Please try again.');
    }
  }

  bool _isConnectivityIssue(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  String _resolveBackendMessage(String? message) {
    if (message == null || message.isEmpty) {
      return 'Login failed. Please try again.';
    }
    return message;
  }

  String? _extractBackendMessage(dynamic data) {
    try {
      final map = _asMap(data);
      final responseDto = LoginResponseDto.fromJson(map);
      return responseDto.errorMessage;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    }

    throw const FormatException('Invalid response format');
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
