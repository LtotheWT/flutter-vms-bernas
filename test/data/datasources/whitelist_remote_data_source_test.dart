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
}
