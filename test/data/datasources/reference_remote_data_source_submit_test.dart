import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';
import 'package:vms_bernas/data/models/permanent_contractor_submit_request_dto.dart';

void main() {
  test('posts check-in payload with Idempotency-Key header', () async {
    final dio = Dio();
    String? capturedPath;
    Map<String, dynamic>? capturedHeaders;
    dynamic capturedData;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedPath = options.path;
          capturedHeaders = Map<String, dynamic>.from(options.headers);
          capturedData = options.data;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'Status': true,
                'Message': null,
                'Details': {
                  'Success': true,
                  'Message': 'Checked-in successfully.',
                },
              },
            ),
          );
        },
      ),
    );
    final dataSource = ReferenceRemoteDataSource(dio);

    final dto = await dataSource.submitPermanentContractorCheckIn(
      accessToken: 'token',
      idempotencyKey: 'idem-123',
      request: const PermanentContractorSubmitRequestDto(
        contractorId: 'C0023',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
    );

    expect(capturedPath, '/wmsws/Contractor/check-in');
    expect(capturedHeaders?['Idempotency-Key'], 'idem-123');
    expect((capturedData as Map<String, dynamic>)['ContractorId'], 'C0023');
    expect(dto.status, isTrue);
  });

  test('posts check-out payload to correct endpoint', () async {
    final dio = Dio();
    String? capturedPath;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedPath = options.path;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {'Success': true, 'Message': 'Checked-out successfully.'},
            ),
          );
        },
      ),
    );
    final dataSource = ReferenceRemoteDataSource(dio);

    final dto = await dataSource.submitPermanentContractorCheckOut(
      accessToken: 'token',
      idempotencyKey: 'idem-321',
      request: const PermanentContractorSubmitRequestDto(
        contractorId: 'C0023',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
    );

    expect(capturedPath, '/wmsws/Contractor/check-out');
    expect(dto.status, isTrue);
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
                'Status': true,
                'Message': null,
                'Details': {'Success': false, 'Message': 'Duplicate IN record'},
              },
            ),
          );
        },
      ),
    );
    final dataSource = ReferenceRemoteDataSource(dio);

    expect(
      () => dataSource.submitPermanentContractorCheckIn(
        accessToken: 'token',
        idempotencyKey: 'idem-123',
        request: const PermanentContractorSubmitRequestDto(
          contractorId: 'C0023',
          site: 'FACTORY1',
          gate: 'F1_A',
          createdBy: 'Ryan',
        ),
      ),
      throwsA(
        isA<ReferenceException>().having(
          (error) => error.message,
          'message',
          'Duplicate IN record',
        ),
      ),
    );
  });
}
