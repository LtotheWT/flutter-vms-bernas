import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/visitor_check_in_request_dto.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_item_entity.dart';

void main() {
  test('posts check-in payload to correct endpoint', () async {
    final dio = Dio();
    String? capturedPath;
    dynamic capturedData;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedPath = options.path;
          capturedData = options.data;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: const {
                'Success': true,
                'Message': 'Checked-in successfully.',
              },
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    final result = await dataSource.submitVisitorCheckIn(
      accessToken: 'token',
      request: const VisitorCheckInRequestDto(
        userId: 'Ryan',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        gate: 'F1_A',
        invitationId: 'IV20260200038',
        visitors: [
          VisitorCheckInSubmissionItemEntity(
            appId: '123456561231',
            physicalTag: '',
          ),
        ],
      ),
    );

    expect(capturedPath, '/wmsws/Visitor/check-in');
    expect(
      (capturedData as Map<String, dynamic>)['invitationid'],
      'IV20260200038',
    );
    expect(result.success, isTrue);
  });

  test('throws backend message on failed submit', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: const {'Success': false, 'Message': 'Duplicate IN record'},
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    expect(
      () => dataSource.submitVisitorCheckIn(
        accessToken: 'token',
        request: const VisitorCheckInRequestDto(
          userId: 'Ryan',
          entity: 'AGYTEK',
          site: 'FACTORY1',
          gate: 'F1_A',
          invitationId: 'IV20260200038',
          visitors: [],
        ),
      ),
      throwsA(
        isA<VisitorAccessException>().having(
          (error) => error.message,
          'message',
          'Duplicate IN record',
        ),
      ),
    );
  });
}
