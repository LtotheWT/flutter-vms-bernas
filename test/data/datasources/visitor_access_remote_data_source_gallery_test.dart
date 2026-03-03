import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';

void main() {
  test('loads gallery list from gallery-list endpoint', () async {
    final dio = Dio();
    Uri? capturedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: [
                {
                  'photoId': 29,
                  'photoDesc': 'string',
                  'Url': '/visitor/photo/29',
                },
              ],
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    final items = await dataSource.getVisitorGalleryList(
      accessToken: 'token',
      invitationId: 'IV20260300016',
    );

    expect(items.length, 1);
    expect(items.first.photoId, 29);
    expect(
      capturedUri.toString(),
      contains('/wmsws/Visitor/gallery-list/IV20260300016'),
    );
  });

  test('loads gallery photo bytes from photo endpoint', () async {
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

    final bytes = await dataSource.getVisitorGalleryPhoto(
      accessToken: 'token',
      photoId: 29,
    );

    expect(bytes, [1, 2, 3]);
    expect(capturedUri.toString(), contains('/wmsws/Visitor/photo/29'));
  });

  test('gallery photo returns null for 404', () async {
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

    final bytes = await dataSource.getVisitorGalleryPhoto(
      accessToken: 'token',
      photoId: 29,
    );
    expect(bytes, isNull);
  });
}
