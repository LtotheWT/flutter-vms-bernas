import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/invitation_remote_data_source.dart';

void main() {
  test('cancelInvitation calls encoded cancel endpoint', () async {
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
                'Message': 'Visitor deleted successfully',
                'Details': null,
              },
            ),
          );
        },
      ),
    );
    final dataSource = InvitationRemoteDataSource(dio);

    final result = await dataSource.cancelInvitation(
      accessToken: 'token',
      invitationId: 'IV20260300043',
    );

    expect(
      capturedUri.toString(),
      contains('/wmsws/Invitations/IV20260300043/cancel'),
    );
    expect(result.status, isTrue);
  });
}
