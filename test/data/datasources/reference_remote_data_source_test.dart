import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';

void main() {
  test('parses permanent contractor info from wrapper Details', () async {
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
                  'CONTR_ID': 'C0023',
                  'CONTR_NAME': 'Dylan Myer',
                  'CONTR_IC': '',
                  'HP_NO': '0111111111',
                  'EMAIL': 'angypin8978@gmail.com',
                  'COMPANY': 'MMG (M) SDN BHD',
                  'VALID_WORKING_DATE_FROM': '2026-01-01T00:00:00',
                  'VALID_WORKING_DATE_TO': '2026-12-31T00:00:00',
                },
              },
            ),
          );
        },
      ),
    );

    final dataSource = ReferenceRemoteDataSource(dio);
    final result = await dataSource.getPermanentContractorInfo(
      accessToken: 'token',
      code: 'CON|C0023||',
    );

    expect(result.contractorId, 'C0023');
    expect(result.contractorName, 'Dylan Myer');
    expect(
      capturedUri.toString(),
      contains('/wmsws/Contractor/CON%7CC0023%7C%7C'),
    );
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
                'Message': 'Contractor not found',
                'Details': null,
              },
            ),
          );
        },
      ),
    );

    final dataSource = ReferenceRemoteDataSource(dio);

    expect(
      () => dataSource.getPermanentContractorInfo(
        accessToken: 'token',
        code: 'CON|BAD||',
      ),
      throwsA(
        isA<ReferenceException>().having(
          (error) => error.message,
          'message',
          'Contractor not found',
        ),
      ),
    );
  });

  test('gets dashboard summary with entity query', () async {
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
                  'VisitorIO': [
                    {
                      'Entity': 'AGYTEK',
                      'TotalInRecords': 839,
                      'TotalOutRecords': 661,
                      'StillInCount': 178,
                    },
                  ],
                  'ContrIO': [
                    {
                      'Entity': 'AGYTEK',
                      'TotalInRecords': 36,
                      'TotalOutRecords': 30,
                      'StillInCount': 6,
                    },
                  ],
                  'WhitelistIO': [
                    {
                      'Entity': 'AGYTEK',
                      'TotalInRecords': 38,
                      'TotalOutRecords': 38,
                      'StillInCount': 0,
                    },
                  ],
                },
              },
            ),
          );
        },
      ),
    );

    final dataSource = ReferenceRemoteDataSource(dio);
    final result = await dataSource.getDashboardSummary(
      accessToken: 'token',
      entity: 'AGYTEK',
    );

    expect(capturedUri.toString(), contains('/wmsws/Ref/dashboard'));
    expect(capturedUri?.queryParameters['entity'], 'AGYTEK');
    expect(result.status, isTrue);
    expect(result.visitor.totalInRecords, 839);
  });

  test('dashboard maps wrapper failure message', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': false,
                'Message': 'Entity is not allowed',
                'Details': null,
              },
            ),
          );
        },
      ),
    );

    final dataSource = ReferenceRemoteDataSource(dio);

    expect(
      () => dataSource.getDashboardSummary(
        accessToken: 'token',
        entity: 'AGYTEK',
      ),
      throwsA(
        isA<ReferenceException>().having(
          (error) => error.message,
          'message',
          'Entity is not allowed',
        ),
      ),
    );
  });
}
