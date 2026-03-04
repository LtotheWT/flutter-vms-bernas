import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';

void main() {
  test('calls delete endpoint and parses response', () async {
    final dio = Dio();
    Uri? capturedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {'success': true, 'message': 'Photo deleted successfully'},
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    final result = await dataSource.deleteVisitorGalleryPhoto(
      accessToken: 'token',
      photoId: 32,
    );

    expect(capturedUri.toString(), contains('/wmsws/Visitor/photo/32/delete'));
    expect(result.success, isTrue);
  });

  test('maps auth failure', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 401,
              ),
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    expect(
      () => dataSource.deleteVisitorGalleryPhoto(
        accessToken: 'token',
        photoId: 32,
      ),
      throwsA(
        isA<VisitorAccessException>().having(
          (e) => e.message,
          'message',
          'Please login again to delete gallery photo.',
        ),
      ),
    );
  });
}
