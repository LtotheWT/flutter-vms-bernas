import 'package:dio/dio.dart';

import 'network/remote_parsers.dart';
import '../models/ref_department_dto.dart';
import '../models/ref_entity_dto.dart';
import '../models/ref_location_dto.dart';
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
}

class ReferenceException implements Exception {
  ReferenceException(this.message);

  final String message;

  @override
  String toString() => message;
}
