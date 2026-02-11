import 'package:dio/dio.dart';

import '../../config/api_config.dart';

Dio createDio(ApiConfig config) {
  return Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {
        'accept': '*/*',
      },
    ),
  );
}
