import 'package:dio/dio.dart';

import '../models/visitor_lookup_dto.dart';
import '../models/visitor_lookup_response_dto.dart';
import 'network/remote_parsers.dart';

class VisitorAccessRemoteDataSource {
  VisitorAccessRemoteDataSource(this._dio);

  final Dio _dio;

  Future<VisitorLookupDto> getVisitorLookup({
    required String accessToken,
    required String code,
    required bool isCheckIn,
  }) async {
    final encodedCode = Uri.encodeComponent(code.trim());

    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Visitor/list/$encodedCode',
        queryParameters: {'checkType': isCheckIn ? 'I' : 'O'},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final dto = VisitorLookupResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw VisitorAccessException(
          _resolveBackendMessage(dto.message) ??
              'Failed to load visitor check data. Please try again.',
        );
      }

      final details = dto.details;
      if (details == null) {
        throw VisitorAccessException(
          'Failed to load visitor check data. Please try again.',
        );
      }
      return details;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw VisitorAccessException(
          'Please login again to load visitor data.',
        );
      }

      final backendMessage = _extractBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw VisitorAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw VisitorAccessException(
          'Unable to load visitor check data. Please try again.',
        );
      }

      throw VisitorAccessException(
        'Failed to load visitor check data. Please try again.',
      );
    } on FormatException {
      throw VisitorAccessException(
        'Failed to load visitor check data. Please try again.',
      );
    }
  }

  String? _extractBackendMessage(dynamic data) {
    try {
      final dto = VisitorLookupResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }

  String? _resolveBackendMessage(String? message) {
    final text = message?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class VisitorAccessException implements Exception {
  VisitorAccessException(this.message);

  final String message;

  @override
  String toString() => message;
}
