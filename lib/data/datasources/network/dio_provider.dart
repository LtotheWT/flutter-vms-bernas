import 'package:dio/dio.dart';

import '../../config/api_config.dart';

typedef UnauthorizedCallback = Future<void> Function();

Dio createDio(ApiConfig config, {UnauthorizedCallback? onUnauthorized}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {'accept': '*/*'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        if ((statusCode == 401 || statusCode == 403) &&
            onUnauthorized != null) {
          await onUnauthorized();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}
