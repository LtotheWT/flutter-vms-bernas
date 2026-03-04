import 'package:dio/dio.dart';

import '../models/whitelist_search_item_dto.dart';
import '../models/whitelist_search_request_dto.dart';
import '../models/whitelist_search_response_dto.dart';
import 'network/remote_parsers.dart';

class WhitelistRemoteDataSource {
  WhitelistRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<WhitelistSearchItemDto>> searchWhitelist({
    required String accessToken,
    required WhitelistSearchRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Whitelist/search',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final root = parseJsonMap(response.data);
      final dto = WhitelistSearchResponseDto.fromJson(root);

      if (!dto.status) {
        throw WhitelistException(
          dto.message?.trim().isNotEmpty == true
              ? dto.message!.trim()
              : 'Failed to load whitelist records. Please try again.',
        );
      }

      if (root['Details'] is! List) {
        throw WhitelistException(
          'Failed to load whitelist records. Please try again.',
        );
      }

      return dto.details;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw WhitelistException('Please login again to load whitelist data.');
      }

      final backendMessage = _extractBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw WhitelistException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw WhitelistException(
          'Unable to load whitelist records. Please try again.',
        );
      }

      throw WhitelistException(
        'Failed to load whitelist records. Please try again.',
      );
    } on FormatException {
      throw WhitelistException(
        'Failed to load whitelist records. Please try again.',
      );
    }
  }

  String? _extractBackendMessage(dynamic data) {
    try {
      final dto = WhitelistSearchResponseDto.fromJson(parseJsonMap(data));
      final message = dto.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class WhitelistException implements Exception {
  WhitelistException(this.message);

  final String message;

  @override
  String toString() => message;
}
