import 'package:dio/dio.dart';
import 'dart:typed_data';

import 'network/remote_parsers.dart';
import '../models/ref_department_dto.dart';
import '../models/ref_entity_dto.dart';
import '../models/ref_location_dto.dart';
import '../models/permanent_contractor_info_dto.dart';
import '../models/permanent_contractor_submit_request_dto.dart';
import '../models/permanent_contractor_submit_response_dto.dart';
import '../models/ref_personel_dto.dart';
import '../models/ref_visitor_type_dto.dart';

class ReferenceRemoteDataSource {
  ReferenceRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<RefEntityDto>> getEntities({required String accessToken}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Ref/entity',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .map((item) => RefEntityDto.fromJson(parseJsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException('Please login again to load entities.');
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException('Unable to load entities. Please try again.');
      }

      throw ReferenceException('Failed to load entities. Please try again.');
    } on FormatException {
      throw ReferenceException('Failed to load entities. Please try again.');
    }
  }

  Future<List<RefDepartmentDto>> getDepartments({
    required String accessToken,
    required String entity,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Ref/departments',
        queryParameters: {'entity': entity},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .map((item) => RefDepartmentDto.fromJson(parseJsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException('Please login again to load departments.');
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException(
          'Unable to load departments. Please try again.',
        );
      }

      throw ReferenceException('Failed to load departments. Please try again.');
    } on FormatException {
      throw ReferenceException('Failed to load departments. Please try again.');
    }
  }

  Future<List<RefLocationDto>> getLocations({
    required String accessToken,
    required String entity,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Ref/locations',
        queryParameters: {'entity': entity},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .map((item) => RefLocationDto.fromJson(parseJsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException('Please login again to load locations.');
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException('Unable to load locations. Please try again.');
      }

      throw ReferenceException('Failed to load locations. Please try again.');
    } on FormatException {
      throw ReferenceException('Failed to load locations. Please try again.');
    }
  }

  Future<List<RefPersonelDto>> getPersonels({
    required String accessToken,
    required String entity,
    required String site,
    required String department,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Ref/personel',
        queryParameters: {'entity': entity, 'site': site, 'dept': department},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .map((item) => RefPersonelDto.fromJson(parseJsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException('Please login again to load hosts.');
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException('Unable to load hosts. Please try again.');
      }

      throw ReferenceException('Failed to load hosts. Please try again.');
    } on FormatException {
      throw ReferenceException('Failed to load hosts. Please try again.');
    }
  }

  Future<List<RefVisitorTypeDto>> getVisitorTypes({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Ref/visitor-type',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final list = parseJsonList(response.data);
      return list
          .map((item) => RefVisitorTypeDto.fromJson(parseJsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException('Please login again to load visitor types.');
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException(
          'Unable to load visitor types. Please try again.',
        );
      }

      throw ReferenceException(
        'Failed to load visitor types. Please try again.',
      );
    } on FormatException {
      throw ReferenceException(
        'Failed to load visitor types. Please try again.',
      );
    }
  }

  Future<PermanentContractorInfoDto> getPermanentContractorInfo({
    required String accessToken,
    required String code,
  }) async {
    try {
      final encodedCode = Uri.encodeComponent(code.trim());
      final response = await _dio.get<dynamic>(
        '/wmsws/Contractor/$encodedCode',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'accept': '*/*'},
        ),
      );

      final root = parseJsonMap(response.data);
      final isSuccess = root['Status'] == true;
      if (!isSuccess) {
        final backendMessage = _resolveBackendMessage(root['Message']);
        throw ReferenceException(
          backendMessage ??
              'Failed to load permanent contractor info. Please try again.',
        );
      }

      final details = parseJsonMap(root['Details']);
      return PermanentContractorInfoDto.fromJson(details);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException(
          'Please login again to load permanent contractor info.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException(
          'Unable to load permanent contractor info. Please try again.',
        );
      }

      throw ReferenceException(
        'Failed to load permanent contractor info. Please try again.',
      );
    } on FormatException {
      throw ReferenceException(
        'Failed to load permanent contractor info. Please try again.',
      );
    }
  }

  Future<Uint8List?> getPermanentContractorImage({
    required String accessToken,
    required String contractorId,
  }) async {
    final encodedContractorId = Uri.encodeComponent(contractorId.trim());
    try {
      final response = await _dio.get<dynamic>(
        '/wmsws/Contractor/image/$encodedContractorId',
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
        throw ReferenceException(
          'Please login again to load permanent contractor image.',
        );
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException(
          'Unable to load permanent contractor image. Please try again.',
        );
      }

      throw ReferenceException(
        'Failed to load permanent contractor image. Please try again.',
      );
    } on FormatException {
      throw ReferenceException(
        'Failed to load permanent contractor image. Please try again.',
      );
    }
  }

  Future<PermanentContractorSubmitResponseDto>
  submitPermanentContractorCheckIn({
    required String accessToken,
    required String idempotencyKey,
    required PermanentContractorSubmitRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Contractor/check-in',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      final dto = PermanentContractorSubmitResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw ReferenceException(
          _resolveBackendMessage(dto.message) ??
              'Failed to submit permanent contractor check-in. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException(
          'Please login again to submit permanent contractor check-in.',
        );
      }

      final backendMessage = _extractSubmitBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw ReferenceException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException(
          'Unable to submit permanent contractor check-in. Please try again.',
        );
      }

      throw ReferenceException(
        'Failed to submit permanent contractor check-in. Please try again.',
      );
    } on FormatException {
      throw ReferenceException(
        'Failed to submit permanent contractor check-in. Please try again.',
      );
    }
  }

  Future<PermanentContractorSubmitResponseDto>
  submitPermanentContractorCheckOut({
    required String accessToken,
    required String idempotencyKey,
    required PermanentContractorSubmitRequestDto request,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/wmsws/Contractor/check-out',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      final dto = PermanentContractorSubmitResponseDto.fromJson(
        parseJsonMap(response.data),
      );
      if (!dto.status) {
        throw ReferenceException(
          _resolveBackendMessage(dto.message) ??
              'Failed to submit permanent contractor check-out. Please try again.',
        );
      }
      return dto;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw ReferenceException(
          'Please login again to submit permanent contractor check-out.',
        );
      }

      final backendMessage = _extractSubmitBackendMessage(error.response?.data);
      if (backendMessage != null) {
        throw ReferenceException(backendMessage);
      }

      if (isConnectivityIssue(error)) {
        throw ReferenceException(
          'Unable to submit permanent contractor check-out. Please try again.',
        );
      }

      throw ReferenceException(
        'Failed to submit permanent contractor check-out. Please try again.',
      );
    } on FormatException {
      throw ReferenceException(
        'Failed to submit permanent contractor check-out. Please try again.',
      );
    }
  }

  String? _resolveBackendMessage(dynamic message) {
    if (message == null) {
      return null;
    }
    final normalized = message.toString().trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return null;
    }
    return normalized;
  }

  String? _extractSubmitBackendMessage(dynamic data) {
    try {
      final dto = PermanentContractorSubmitResponseDto.fromJson(
        parseJsonMap(data),
      );
      return _resolveBackendMessage(dto.message);
    } catch (_) {
      return null;
    }
  }
}

class ReferenceException implements Exception {
  ReferenceException(this.message);

  final String message;

  @override
  String toString() => message;
}
