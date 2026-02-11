import 'package:dio/dio.dart';

import 'network/remote_parsers.dart';
import '../models/ref_entity_dto.dart';

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
}

class ReferenceException implements Exception {
  ReferenceException(this.message);

  final String message;

  @override
  String toString() => message;
}
