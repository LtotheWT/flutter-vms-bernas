import 'package:dio/dio.dart';
import 'dart:typed_data';

import '../models/employee_delete_photo_response_dto.dart';
import '../models/employee_gallery_item_dto.dart';
import '../models/employee_info_response_dto.dart';
import '../models/employee_save_photo_request_dto.dart';
import '../models/employee_save_photo_response_dto.dart';
import '../models/employee_submit_request_dto.dart';
import '../models/employee_submit_response_dto.dart';
import 'network/remote_parsers.dart';

class EmployeeAccessRemoteDataSource {
  EmployeeAccessRemoteDataSource(this._dio);

  final Dio _dio;

  Future<EmployeeInfoDto> getEmployeeInfo({
    required String accessToken,
    required String code,
  }) async {
    final encodedCode = Uri.encodeComponent(code.trim());
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Employee/$encodedCode',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final dto = EmployeeInfoResponseDto.fromJson(parseJsonMap(response.data));
      if (!dto.status) {
        throw EmployeeAccessException(
          _resolveBackendMessage(dto.message) ??
              'Failed to load employee info. Please try again.',
        );
      }
      final details = dto.details;
      if (details == null) {
        throw EmployeeAccessException(
          'Failed to load employee info. Please try again.',
        );
      }
      return details;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw EmployeeAccessException(
          'Please login again to load employee info.',
        );
      }

      final backendMessage = _extractLookupBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw EmployeeAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw EmployeeAccessException(
          'Unable to load employee info. Please try again.',
        );
      }

      throw EmployeeAccessException(
        'Failed to load employee info. Please try again.',
      );
    } on FormatException {
      throw EmployeeAccessException(
        'Failed to load employee info. Please try again.',
      );
    }
  }

  Future<EmployeeSubmitResponseDto> submitEmployeeCheckIn({
    required String accessToken,
    required String idempotencyKey,
    required EmployeeSubmitRequestDto request,
  }) {
    return _submit(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: request,
      endpoint: '/wmsws/Employee/check-in',
      unauthorizedMessage: 'Please login again to submit employee check-in.',
      connectivityMessage:
          'Unable to submit employee check-in. Please try again.',
      fallbackMessage: 'Failed to submit employee check-in. Please try again.',
    );
  }

  Future<Uint8List?> getEmployeeImage({
    required String accessToken,
    required String employeeId,
  }) async {
    final encodedEmployeeId = Uri.encodeComponent(employeeId.trim());
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Employee/$encodedEmployeeId/photo',
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
        throw EmployeeAccessException(
          'Please login again to load employee image.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw EmployeeAccessException(
          'Unable to load employee image. Please try again.',
        );
      }

      throw EmployeeAccessException(
        'Failed to load employee image. Please try again.',
      );
    } on FormatException {
      throw EmployeeAccessException(
        'Failed to load employee image. Please try again.',
      );
    }
  }

  Future<List<EmployeeGalleryItemDto>> getEmployeeGalleryList({
    required String accessToken,
    required String guid,
  }) async {
    final encodedGuid = Uri.encodeComponent(guid.trim());
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Employee/gallery-list/$encodedGuid',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .whereType<Map>()
          .map(
            (item) => EmployeeGalleryItemDto.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw EmployeeAccessException(
          'Please login again to load employee gallery.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw EmployeeAccessException(
          'Unable to load employee gallery. Please try again.',
        );
      }

      throw EmployeeAccessException(
        'Failed to load employee gallery. Please try again.',
      );
    } on FormatException {
      throw EmployeeAccessException(
        'Failed to load employee gallery. Please try again.',
      );
    }
  }

  Future<Uint8List?> getEmployeeGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Employee/photo/$photoId',
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
        throw EmployeeAccessException(
          'Please login again to load employee gallery photo.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw EmployeeAccessException(
          'Unable to load employee gallery photo. Please try again.',
        );
      }

      throw EmployeeAccessException(
        'Failed to load employee gallery photo. Please try again.',
      );
    } on FormatException {
      throw EmployeeAccessException(
        'Failed to load employee gallery photo. Please try again.',
      );
    }
  }

  Future<EmployeeSavePhotoResponseDto> saveEmployeePhoto({
    required String accessToken,
    required EmployeeSavePhotoRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Employee/save-photo',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final dto = EmployeeSavePhotoResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.success) {
        throw EmployeeAccessException(
          _resolveBackendMessage(dto.message) ??
              'Failed to upload employee photo. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw EmployeeAccessException('Please login again to upload photo.');
      }

      final backendMessage = _extractSavePhotoBackendMessage(
        error.response?.data,
      );
      if (backendMessage != null) {
        throw EmployeeAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw EmployeeAccessException(
          'Unable to upload employee photo. Please try again.',
        );
      }

      throw EmployeeAccessException(
        'Failed to upload employee photo. Please try again.',
      );
    } on FormatException {
      throw EmployeeAccessException(
        'Failed to upload employee photo. Please try again.',
      );
    }
  }

  Future<EmployeeDeletePhotoResponseDto> deleteEmployeeGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        '/wmsws/Employee/photo/$photoId/delete',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final dto = EmployeeDeletePhotoResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw EmployeeAccessException(
          _resolveBackendMessage(dto.message) ??
              'Failed to delete employee photo. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw EmployeeAccessException(
          'Please login again to delete employee photo.',
        );
      }

      final backendMessage = _extractDeletePhotoBackendMessage(
        error.response?.data,
      );
      if (backendMessage != null) {
        throw EmployeeAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw EmployeeAccessException(
          'Unable to delete employee photo. Please try again.',
        );
      }

      throw EmployeeAccessException(
        'Failed to delete employee photo. Please try again.',
      );
    } on FormatException {
      throw EmployeeAccessException(
        'Failed to delete employee photo. Please try again.',
      );
    }
  }

  Future<EmployeeSubmitResponseDto> submitEmployeeCheckOut({
    required String accessToken,
    required String idempotencyKey,
    required EmployeeSubmitRequestDto request,
  }) {
    return _submit(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: request,
      endpoint: '/wmsws/Employee/check-out',
      unauthorizedMessage: 'Please login again to submit employee check-out.',
      connectivityMessage:
          'Unable to submit employee check-out. Please try again.',
      fallbackMessage: 'Failed to submit employee check-out. Please try again.',
    );
  }

  Future<EmployeeSubmitResponseDto> _submit({
    required String accessToken,
    required String idempotencyKey,
    required EmployeeSubmitRequestDto request,
    required String endpoint,
    required String unauthorizedMessage,
    required String connectivityMessage,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      final dto = EmployeeSubmitResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw EmployeeAccessException(
          dto.message.isNotEmpty ? dto.message : fallbackMessage,
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw EmployeeAccessException(unauthorizedMessage);
      }

      final backendMessage = _extractSubmitBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw EmployeeAccessException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw EmployeeAccessException(connectivityMessage);
      }

      throw EmployeeAccessException(fallbackMessage);
    } on FormatException {
      throw EmployeeAccessException(fallbackMessage);
    }
  }

  String? _resolveBackendMessage(String? message) {
    final text = (message ?? '').trim();
    return text.isEmpty ? null : text;
  }

  String? _extractLookupBackendMessage(dynamic data) {
    try {
      final dto = EmployeeInfoResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }

  String? _extractSubmitBackendMessage(dynamic data) {
    try {
      final dto = EmployeeSubmitResponseDto.fromJson(parseJsonMap(data));
      final text = dto.message.trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  String? _extractSavePhotoBackendMessage(dynamic data) {
    try {
      final dto = EmployeeSavePhotoResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }

  String? _extractDeletePhotoBackendMessage(dynamic data) {
    try {
      final dto = EmployeeDeletePhotoResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }
}

class EmployeeAccessException implements Exception {
  EmployeeAccessException(this.message);

  final String message;

  @override
  String toString() => message;
}
