import 'package:dio/dio.dart';
import 'dart:typed_data';

import '../models/visitor_check_in_request_dto.dart';
import '../models/visitor_check_in_response_dto.dart';
import '../models/visitor_gallery_item_dto.dart';
import '../models/visitor_lookup_dto.dart';
import '../models/visitor_lookup_response_dto.dart';
import '../models/visitor_save_photo_request_dto.dart';
import '../models/visitor_save_photo_response_dto.dart';
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

  Future<VisitorCheckInResponseDto> submitVisitorCheckIn({
    required String accessToken,
    required VisitorCheckInRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Visitor/check-in',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final dto = VisitorCheckInResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw VisitorAccessException(
          _resolveBackendMessage(dto.message) ??
              'Failed to submit visitor check-in. Please try again. ${response.data}',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw VisitorAccessException('Please login again to submit check-in.');
      }

      final backendMessage = _extractCheckInBackendMessage(
        error.response?.data,
      );
      if (backendMessage != null) {
        throw VisitorAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw VisitorAccessException(
          'Unable to submit visitor check-in. Please try again.',
        );
      }

      throw VisitorAccessException(
        'Failed to submit visitor check-in. Please try again. $error',
      );
    } on FormatException catch (error) {
      throw VisitorAccessException(
        'Failed to submit visitor check-in. Please try again. $error',
      );
    }
  }

  Future<VisitorCheckInResponseDto> submitVisitorCheckOut({
    required String accessToken,
    required VisitorCheckInRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Visitor/check-out',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final dto = VisitorCheckInResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw VisitorAccessException(
          _resolveBackendMessage(dto.message) ??
              'Failed to submit visitor check-out. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw VisitorAccessException('Please login again to submit check-out.');
      }

      final backendMessage = _extractCheckInBackendMessage(
        error.response?.data,
      );
      if (backendMessage != null) {
        throw VisitorAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw VisitorAccessException(
          'Unable to submit visitor check-out. Please try again.',
        );
      }

      throw VisitorAccessException(
        'Failed to submit visitor check-out. Please try again.',
      );
    } on FormatException {
      throw VisitorAccessException(
        'Failed to submit visitor check-out. Please try again.',
      );
    }
  }

  Future<Uint8List?> getVisitorApplicantImage({
    required String accessToken,
    required String invitationId,
    required String appId,
  }) async {
    final encodedInvitationId = Uri.encodeComponent(invitationId.trim());
    final encodedAppId = Uri.encodeComponent(appId.trim());

    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Visitor/applicant-image/$encodedInvitationId/$encodedAppId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
          responseType: ResponseType.bytes,
        ),
      );

      final data = response.data;
      if (data is Uint8List) {
        return data.isEmpty ? null : data;
      }
      if (data is List<int>) {
        return data.isEmpty ? null : Uint8List.fromList(data);
      }
      return null;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return null;
      }
      if (statusCode == 401 || statusCode == 403) {
        throw VisitorAccessException(
          'Please login again to load visitor image.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw VisitorAccessException(
          'Unable to load visitor image. Please try again.',
        );
      }

      throw VisitorAccessException(
        'Failed to load visitor image. Please try again.',
      );
    } on FormatException {
      throw VisitorAccessException(
        'Failed to load visitor image. Please try again.',
      );
    }
  }

  Future<List<VisitorGalleryItemDto>> getVisitorGalleryList({
    required String accessToken,
    required String invitationId,
  }) async {
    final encodedInvitationId = Uri.encodeComponent(invitationId.trim());

    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Visitor/gallery-list/$encodedInvitationId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .whereType<Map>()
          .map(
            (item) => VisitorGalleryItemDto.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw VisitorAccessException(
          'Please login again to load visitor gallery.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw VisitorAccessException(
          'Unable to load visitor gallery. Please try again.',
        );
      }

      throw VisitorAccessException(
        'Failed to load visitor gallery. Please try again.',
      );
    } on FormatException {
      throw VisitorAccessException(
        'Failed to load visitor gallery. Please try again.',
      );
    }
  }

  Future<Uint8List?> getVisitorGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Visitor/photo/$photoId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
          responseType: ResponseType.bytes,
        ),
      );

      final data = response.data;
      if (data is Uint8List) {
        return data.isEmpty ? null : data;
      }
      if (data is List<int>) {
        return data.isEmpty ? null : Uint8List.fromList(data);
      }
      return null;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return null;
      }
      if (statusCode == 401 || statusCode == 403) {
        throw VisitorAccessException(
          'Please login again to load gallery photo.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw VisitorAccessException(
          'Unable to load gallery photo. Please try again.',
        );
      }

      throw VisitorAccessException(
        'Failed to load gallery photo. Please try again.',
      );
    } on FormatException {
      throw VisitorAccessException(
        'Failed to load gallery photo. Please try again.',
      );
    }
  }

  Future<VisitorSavePhotoResponseDto> saveVisitorPhoto({
    required String accessToken,
    required VisitorSavePhotoRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Visitor/save-photo',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final dto = VisitorSavePhotoResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.success) {
        throw VisitorAccessException(
          _resolveBackendMessage(dto.message) ??
              'Failed to upload visitor photo. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw VisitorAccessException('Please login again to upload photo.');
      }

      final backendMessage = _extractSavePhotoBackendMessage(
        error.response?.data,
      );
      if (backendMessage != null) {
        throw VisitorAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw VisitorAccessException(
          'Unable to upload visitor photo. Please try again.',
        );
      }

      throw VisitorAccessException(
        'Failed to upload visitor photo. Please try again.',
      );
    } on FormatException {
      throw VisitorAccessException(
        'Failed to upload visitor photo. Please try again.',
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

  String? _extractCheckInBackendMessage(dynamic data) {
    try {
      final dto = VisitorCheckInResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }

  String? _extractSavePhotoBackendMessage(dynamic data) {
    try {
      final dto = VisitorSavePhotoResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }
}

class VisitorAccessException implements Exception {
  VisitorAccessException(this.message);

  final String message;

  @override
  String toString() => message;
}
