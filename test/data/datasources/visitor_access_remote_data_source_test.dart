import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';

void main() {
  test('sends encoded path and checkType query parameter', () async {
    final dio = Dio();
    Uri? capturedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': true,
                'Message': null,
                'Details': {
                  'invitationId': 'IV20260200038',
                  'entity': 'AGYTEK',
                  'site': 'FACTORY1',
                  'visitorList': [],
                },
              },
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    final result = await dataSource.getVisitorLookup(
      accessToken: 'token',
      code: 'VIS|IV20260200038|AGYTEK|FACTORY1',
      isCheckIn: true,
    );

    expect(result.invitationId, 'IV20260200038');
    expect(capturedUri, isNotNull);
    expect(
      capturedUri.toString(),
      contains('/wmsws/Visitor/list/VIS%7CIV20260200038%7CAGYTEK%7CFACTORY1'),
    );
    expect(capturedUri?.queryParameters['checkType'], 'I');
  });

  test('throws backend message when status is false', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': false,
                'Message': 'Invalid code',
                'Details': null,
              },
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    expect(
      () => dataSource.getVisitorLookup(
        accessToken: 'token',
        code: 'VIS|BAD|AGYTEK|FACTORY1',
        isCheckIn: false,
      ),
      throwsA(
        isA<VisitorAccessException>().having(
          (error) => error.message,
          'message',
          'Invalid code',
        ),
      ),
    );
  });
}
