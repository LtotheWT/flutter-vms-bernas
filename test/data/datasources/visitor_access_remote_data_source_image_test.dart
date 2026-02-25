import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';

void main() {
  test('loads image bytes from applicant-image endpoint', () async {
    final dio = Dio();
    Uri? capturedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: Uint8List.fromList([1, 2, 3]),
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    final bytes = await dataSource.getVisitorApplicantImage(
      accessToken: 'token',
      invitationId: 'IV20260200038',
      appId: '12345656123',
    );

    expect(bytes, isNotNull);
    expect(bytes, [1, 2, 3]);
    expect(
      capturedUri.toString(),
      contains('/wmsws/Visitor/applicant-image/IV20260200038/12345656123'),
    );
  });

  test('returns null when endpoint responds 404', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 404,
              ),
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    final bytes = await dataSource.getVisitorApplicantImage(
      accessToken: 'token',
      invitationId: 'IV1',
      appId: 'APP1',
    );
    expect(bytes, isNull);
  });

  test('throws generic error for non-404 failures', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 500,
              ),
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    expect(
      () => dataSource.getVisitorApplicantImage(
        accessToken: 'token',
        invitationId: 'IV1',
        appId: 'APP1',
      ),
      throwsA(
        isA<VisitorAccessException>().having(
          (error) => error.message,
          'message',
          'Failed to load visitor image. Please try again.',
        ),
      ),
    );
  });
}
