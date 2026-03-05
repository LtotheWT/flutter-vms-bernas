import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/employee_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/employee_submit_request_dto.dart';

void main() {
  test('gets employee info with encoded code path', () async {
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
                  'EMP_ID': 'EMP0001',
                  'EMP_NAME': 'Suraya',
                  'SITE': 'FACTORY1',
                  'DEPT': 'ADC',
                  'UNIT': 'ABC',
                  'VEHICLE_TYPE': 'CAR',
                  'HP_NO': '2',
                  'TEL_NO': '3',
                  'START_WORKING_DATE': '2025-11-01T00:00:00',
                  'LAST_WORKING_DATE': '2025-11-30T00:00:00',
                },
              },
            ),
          );
        },
      ),
    );

    final dataSource = EmployeeAccessRemoteDataSource(dio);
    final result = await dataSource.getEmployeeInfo(
      accessToken: 'token',
      code: 'EMP|EMP0001||',
    );

    expect(
      capturedUri.toString(),
      contains('/wmsws/Employee/EMP%7CEMP0001%7C%7C'),
    );
    expect(result.employeeId, 'EMP0001');
  });

  test('lookup maps auth failure to relogin message', () async {
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

    final dataSource = EmployeeAccessRemoteDataSource(dio);
    expect(
      () => dataSource.getEmployeeInfo(
        accessToken: 'token',
        code: 'EMP|EMP0001||',
      ),
      throwsA(
        isA<EmployeeAccessException>().having(
          (e) => e.message,
          'message',
          'Please login again to load employee info.',
        ),
      ),
    );
  });

  test('gets employee profile image bytes', () async {
    final dio = Dio();
    Uri? capturedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: Uint8List.fromList(const [1, 2, 3]),
            ),
          );
        },
      ),
    );

    final dataSource = EmployeeAccessRemoteDataSource(dio);
    final result = await dataSource.getEmployeeImage(
      accessToken: 'token',
      employeeId: 'EMP0001',
    );

    expect(capturedUri.toString(), contains('/wmsws/Employee/EMP0001/photo'));
    expect(result, isNotNull);
    expect(result, Uint8List.fromList(const [1, 2, 3]));
  });

  test('employee image returns null on 404', () async {
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

    final dataSource = EmployeeAccessRemoteDataSource(dio);
    final result = await dataSource.getEmployeeImage(
      accessToken: 'token',
      employeeId: 'EMP0001',
    );
    expect(result, isNull);
  });

  test('submits check-in with idempotency key and payload', () async {
    final dio = Dio();
    Uri? capturedUri;
    dynamic capturedBody;
    String? capturedIdempotencyKey;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          capturedBody = options.data;
          capturedIdempotencyKey = options.headers['Idempotency-Key']
              ?.toString();
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': true,
                'Message': 'Employee EMP0001 checked in successfully.',
                'Details': {
                  'EventType': 'IN',
                  'EventDate': '2026-03-05T22:49:10.2640583+08:00',
                  'PhotoGuid': 'idem-1',
                },
              },
            ),
          );
        },
      ),
    );

    final dataSource = EmployeeAccessRemoteDataSource(dio);
    final result = await dataSource.submitEmployeeCheckIn(
      accessToken: 'token',
      idempotencyKey: 'idem-1',
      request: const EmployeeSubmitRequestDto(
        employeeId: 'EMP0001',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
    );

    expect(capturedUri.toString(), contains('/wmsws/Employee/check-in'));
    expect(capturedIdempotencyKey, 'idem-1');
    expect(capturedBody, {
      'EmployeeId': 'EMP0001',
      'Site': 'FACTORY1',
      'Gate': 'F1_A',
      'CreatedBy': 'Ryan',
    });
    expect(result.status, isTrue);
    expect(result.eventType, 'IN');
  });

  test('submits check-out with idempotency key', () async {
    final dio = Dio();
    Uri? capturedUri;
    String? capturedIdempotencyKey;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          capturedIdempotencyKey = options.headers['Idempotency-Key']
              ?.toString();
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': true,
                'Message': 'Employee EMP0001 checked out successfully.',
                'Details': {
                  'EventType': 'OUT',
                  'EventDate': '2026-03-05T22:49:01.5240769+08:00',
                  'PhotoGuid': 'idem-2',
                },
              },
            ),
          );
        },
      ),
    );

    final dataSource = EmployeeAccessRemoteDataSource(dio);
    final result = await dataSource.submitEmployeeCheckOut(
      accessToken: 'token',
      idempotencyKey: 'idem-2',
      request: const EmployeeSubmitRequestDto(
        employeeId: 'EMP0001',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
    );

    expect(capturedUri.toString(), contains('/wmsws/Employee/check-out'));
    expect(capturedIdempotencyKey, 'idem-2');
    expect(result.status, isTrue);
    expect(result.eventType, 'OUT');
  });

  test('submit propagates wrapper failure message', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': false,
                'Message': 'Duplicate IN record.',
                'Details': null,
              },
            ),
          );
        },
      ),
    );

    final dataSource = EmployeeAccessRemoteDataSource(dio);
    expect(
      () => dataSource.submitEmployeeCheckIn(
        accessToken: 'token',
        idempotencyKey: 'idem-3',
        request: const EmployeeSubmitRequestDto(
          employeeId: 'EMP0001',
          site: 'FACTORY1',
          gate: 'F1_A',
          createdBy: 'Ryan',
        ),
      ),
      throwsA(
        isA<EmployeeAccessException>().having(
          (e) => e.message,
          'message',
          'Duplicate IN record.',
        ),
      ),
    );
  });
}
