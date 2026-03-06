import 'package:dio/dio.dart';
import 'dart:typed_data';

import '../models/whitelist_detail_response_dto.dart';
import '../models/whitelist_delete_photo_response_dto.dart';
import '../models/whitelist_gallery_item_dto.dart';
import '../models/whitelist_search_item_dto.dart';
import '../models/whitelist_search_request_dto.dart';
import '../models/whitelist_save_photo_request_dto.dart';
import '../models/whitelist_save_photo_response_dto.dart';
import '../models/whitelist_search_response_dto.dart';
import '../models/whitelist_submit_request_dto.dart';
import '../models/whitelist_submit_response_dto.dart';
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

  Future<WhitelistDetailResponseDto> getWhitelistDetail({
    required String accessToken,
    required String entity,
    required String vehiclePlate,
  }) async {
    final encodedEntity = Uri.encodeComponent(entity.trim());
    final encodedVehiclePlate = Uri.encodeComponent(vehiclePlate.trim());

    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Whitelist/$encodedEntity/$encodedVehiclePlate',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final root = parseJsonMap(response.data);
      final dto = WhitelistDetailResponseDto.fromJson(root);
      if (!dto.status) {
        throw WhitelistException(
          dto.message?.trim().isNotEmpty == true
              ? dto.message!.trim()
              : 'Failed to load whitelist detail. Please try again.',
        );
      }
      if (dto.details == null) {
        throw WhitelistException(
          'Failed to load whitelist detail. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw WhitelistException(
          'Please login again to load whitelist detail.',
        );
      }

      final backendMessage = _extractDetailBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw WhitelistException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw WhitelistException(
          'Unable to load whitelist detail. Please try again.',
        );
      }

      throw WhitelistException(
        'Failed to load whitelist detail. Please try again.',
      );
    } on FormatException {
      throw WhitelistException(
        'Failed to load whitelist detail. Please try again.',
      );
    }
  }

  Future<WhitelistSubmitResponseDto> submitWhitelistCheckIn({
    required String accessToken,
    required String idempotencyKey,
    required WhitelistSubmitRequestDto request,
  }) {
    return _submitWhitelist(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: request,
      endpoint: '/wmsws/Whitelist/check-in',
      unauthorizedMessage: 'Please login again to submit whitelist check-in.',
      connectivityMessage:
          'Unable to submit whitelist check-in. Please try again.',
      fallbackMessage: 'Failed to submit whitelist check-in. Please try again.',
    );
  }

  Future<WhitelistSubmitResponseDto> submitWhitelistCheckOut({
    required String accessToken,
    required String idempotencyKey,
    required WhitelistSubmitRequestDto request,
  }) {
    return _submitWhitelist(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: request,
      endpoint: '/wmsws/Whitelist/check-out',
      unauthorizedMessage: 'Please login again to submit whitelist check-out.',
      connectivityMessage:
          'Unable to submit whitelist check-out. Please try again.',
      fallbackMessage:
          'Failed to submit whitelist check-out. Please try again.',
    );
  }

  Future<List<WhitelistGalleryItemDto>> getWhitelistGalleryList({
    required String accessToken,
    required String guid,
  }) async {
    final encodedGuid = Uri.encodeComponent(guid.trim());

    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Whitelist/gallery-list/$encodedGuid',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .whereType<Map>()
          .map(
            (item) => WhitelistGalleryItemDto.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw WhitelistException(
          'Please login again to load whitelist gallery.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw WhitelistException(
          'Unable to load whitelist gallery. Please try again.',
        );
      }

      throw WhitelistException(
        'Failed to load whitelist gallery. Please try again.',
      );
    } on FormatException {
      throw WhitelistException(
        'Failed to load whitelist gallery. Please try again.',
      );
    }
  }

  Future<Uint8List?> getWhitelistPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Whitelist/photo/$photoId',
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
        throw WhitelistException('Please login again to load whitelist photo.');
      }

      if (isConnectivityIssue(error)) {
        throw WhitelistException(
          'Unable to load whitelist photo. Please try again.',
        );
      }

      throw WhitelistException(
        'Failed to load whitelist photo. Please try again.',
      );
    } on FormatException {
      throw WhitelistException(
        'Failed to load whitelist photo. Please try again.',
      );
    }
  }

  Future<WhitelistSavePhotoResponseDto> saveWhitelistPhoto({
    required String accessToken,
    required WhitelistSavePhotoRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Whitelist/save-photo',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      final dto = WhitelistSavePhotoResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.success) {
        throw WhitelistException(
          _resolveBackendMessage(dto.message) ??
              'Failed to upload whitelist photo. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw WhitelistException('Please login again to upload photo.');
      }

      final backendMessage = _extractSavePhotoBackendMessage(
        error.response?.data,
      );
      if (backendMessage != null) {
        throw WhitelistException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw WhitelistException(
          'Unable to upload whitelist photo. Please try again.',
        );
      }

      throw WhitelistException(
        'Failed to upload whitelist photo. Please try again.',
      );
    } on FormatException {
      throw WhitelistException(
        'Failed to upload whitelist photo. Please try again.',
      );
    }
  }

  Future<WhitelistDeletePhotoResponseDto> deleteWhitelistPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        '/wmsws/Whitelist/photo/$photoId/delete',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final dto = WhitelistDeletePhotoResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw WhitelistException(
          _resolveBackendMessage(dto.message) ??
              'Failed to delete whitelist photo. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw WhitelistException(
          'Please login again to delete whitelist photo.',
        );
      }

      final backendMessage = _extractDeletePhotoBackendMessage(
        error.response?.data,
      );
      if (backendMessage != null) {
        throw WhitelistException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw WhitelistException(
          'Unable to delete whitelist photo. Please try again.',
        );
      }

      throw WhitelistException(
        'Failed to delete whitelist photo. Please try again.',
      );
    } on FormatException {
      throw WhitelistException(
        'Failed to delete whitelist photo. Please try again.',
      );
    }
  }

  Future<WhitelistSubmitResponseDto> _submitWhitelist({
    required String accessToken,
    required String idempotencyKey,
    required WhitelistSubmitRequestDto request,
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

      final dto = WhitelistSubmitResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw WhitelistException(
          dto.message.isNotEmpty ? dto.message : fallbackMessage,
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw WhitelistException(unauthorizedMessage);
      }

      final backendMessage = _extractSubmitBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw WhitelistException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw WhitelistException(connectivityMessage);
      }

      throw WhitelistException(fallbackMessage);
    } on FormatException {
      throw WhitelistException(fallbackMessage);
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

  String? _extractDetailBackendMessage(dynamic data) {
    try {
      final dto = WhitelistDetailResponseDto.fromJson(parseJsonMap(data));
      final message = dto.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractSubmitBackendMessage(dynamic data) {
    try {
      final dto = WhitelistSubmitResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }

  String? _extractSavePhotoBackendMessage(dynamic data) {
    try {
      final dto = WhitelistSavePhotoResponseDto.fromJson(parseJsonMap(data));
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }

  String? _extractDeletePhotoBackendMessage(dynamic data) {
    try {
      final dto = WhitelistDeletePhotoResponseDto.fromJson(parseJsonMap(data));
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

class WhitelistException implements Exception {
  WhitelistException(this.message);

  final String message;

  @override
  String toString() => message;
}
