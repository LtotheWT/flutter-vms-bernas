import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/whitelist_remote_data_source.dart';
import 'package:vms_bernas/data/models/whitelist_search_request_dto.dart';

void main() {
  test('posts to whitelist search endpoint with payload', () async {
    final dio = Dio();
    Uri? capturedUri;
    dynamic capturedBody;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          capturedBody = options.data;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': true,
                'Message': null,
                'Details': [
                  {
                    'ENTITY': 'AGYTEK',
                    'WL_VEHICLE_PLATE': 'RYAN1234',
                    'WL_IC': 'RYAN',
                    'WL_NAME': 'RYAN1234',
                    'STATUS': 'A',
                    'CREATE_BY': 'ryan',
                    'CREATE_DATE': '2026-01-13 11:46:40',
                    'UPDATE_BY': null,
                    'UPDATE_DATE': null,
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final dataSource = WhitelistRemoteDataSource(dio);
    final result = await dataSource.searchWhitelist(
      accessToken: 'token',
      request: const WhitelistSearchRequestDto(
        entity: 'AGYTEK',
        currentType: 'I',
        vehiclePlate: '',
        ic: '',
        status: '',
      ),
    );

    expect(capturedUri.toString(), contains('/wmsws/Whitelist/search'));
    expect(capturedBody, {
      'Entity': 'AGYTEK',
      'CURRENT_TYPE': 'I',
      'VehiclePlate': '',
      'IC': '',
      'STATUS': '',
    });
    expect(result, hasLength(1));
  });

  test('maps auth failure to relogin message', () async {
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

    final dataSource = WhitelistRemoteDataSource(dio);

    expect(
      () => dataSource.searchWhitelist(
        accessToken: 'token',
        request: const WhitelistSearchRequestDto(
          entity: 'AGYTEK',
          currentType: 'O',
          vehiclePlate: '',
          ic: '',
          status: '',
        ),
      ),
      throwsA(
        isA<WhitelistException>().having(
          (e) => e.message,
          'message',
          'Please login again to load whitelist data.',
        ),
      ),
    );
  });

  test('throws backend message when wrapper status is false', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {'Status': false, 'Message': 'Blocked', 'Details': []},
            ),
          );
        },
      ),
    );

    final dataSource = WhitelistRemoteDataSource(dio);

    expect(
      () => dataSource.searchWhitelist(
        accessToken: 'token',
        request: const WhitelistSearchRequestDto(
          entity: 'AGYTEK',
          currentType: 'I',
          vehiclePlate: '',
          ic: '',
          status: '',
        ),
      ),
      throwsA(
        isA<WhitelistException>().having(
          (e) => e.message,
          'message',
          'Blocked',
        ),
      ),
    );
  });

  test('gets whitelist detail with encoded path', () async {
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
                'Message': 'ok',
                'Details': {
                  'ENTITY': 'AGYTEK',
                  'WL_VEHICLE_PLATE': 'www9233G',
                  'WL_IC': '123456789012',
                  'WL_NAME': 'John',
                  'STATUS': 'A',
                  'CREATE_BY': 'admin',
                  'CREATE_DATE': '2025-12-03 10:23:10',
                  'UPDATE_BY': 'admin',
                  'UPDATE_DATE': '2025-12-03 10:48:15',
                },
              },
            ),
          );
        },
      ),
    );

    final dataSource = WhitelistRemoteDataSource(dio);
    final result = await dataSource.getWhitelistDetail(
      accessToken: 'token',
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
    );

    expect(
      capturedUri.toString(),
      contains('/wmsws/Whitelist/AGYTEK/www9233G'),
    );
    expect(result.status, isTrue);
    expect(result.details?.status, 'ACTIVE');
  });

  test('detail endpoint maps auth failure', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 403,
              ),
            ),
          );
        },
      ),
    );

    final dataSource = WhitelistRemoteDataSource(dio);
    expect(
      () => dataSource.getWhitelistDetail(
        accessToken: 'token',
        entity: 'AGYTEK',
        vehiclePlate: 'www9233G',
      ),
      throwsA(
        isA<WhitelistException>().having(
          (e) => e.message,
          'message',
          'Please login again to load whitelist detail.',
        ),
      ),
    );
  });
}
