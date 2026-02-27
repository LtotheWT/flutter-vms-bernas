import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';

void main() {
  test('loads permanent contractor image bytes', () async {
    final dio = Dio();
    Uri? capturedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: Uint8List.fromList([7, 8, 9]),
            ),
          );
        },
      ),
    );
    final dataSource = ReferenceRemoteDataSource(dio);

    final bytes = await dataSource.getPermanentContractorImage(
      accessToken: 'token',
      contractorId: 'c0023',
    );

    expect(bytes, [7, 8, 9]);
    expect(capturedUri.toString(), contains('/wmsws/Contractor/image/c0023'));
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
    final dataSource = ReferenceRemoteDataSource(dio);

    final bytes = await dataSource.getPermanentContractorImage(
      accessToken: 'token',
      contractorId: 'c0023',
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
    final dataSource = ReferenceRemoteDataSource(dio);

    expect(
      () => dataSource.getPermanentContractorImage(
        accessToken: 'token',
        contractorId: 'c0023',
      ),
      throwsA(
        isA<ReferenceException>().having(
          (error) => error.message,
          'message',
          'Failed to load permanent contractor image. Please try again.',
        ),
      ),
    );
  });
}
