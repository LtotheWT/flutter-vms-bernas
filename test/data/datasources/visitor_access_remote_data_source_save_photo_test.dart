import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/visitor_save_photo_request_dto.dart';

void main() {
  test('posts visitor save-photo with expected body and headers', () async {
    final dio = Dio();
    Uri? capturedUri;
    Map<String, dynamic>? capturedData;
    Map<String, dynamic>? capturedHeaders;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          capturedData = Map<String, dynamic>.from(
            options.data as Map<dynamic, dynamic>,
          );
          capturedHeaders = options.headers;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'success': true,
                'message': 'Photo saved successfully',
                'data': {'PhotoId': 31},
              },
            ),
          );
        },
      ),
    );
    final dataSource = VisitorAccessRemoteDataSource(dio);

    final result = await dataSource.saveVisitorPhoto(
      accessToken: 'token',
      request: const VisitorSavePhotoRequestDto(
        imageBase64: 'abc',
        photoDescription: 'desc',
        invitationId: 'IV20260300016',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(capturedUri.toString(), contains('/wmsws/Visitor/save-photo'));
    expect(capturedData?['ImageBase64'], 'abc');
    expect(capturedData?['PhotoDescription'], 'desc');
    expect(capturedData?['InvitationId'], 'IV20260300016');
    expect(capturedData?['Entity'], 'AGYTEK');
    expect(capturedData?['Site'], 'FACTORY1');
    expect(capturedData?['UploadedBy'], 'Ryan');
    expect(capturedHeaders?['Authorization'], 'Bearer token');
    expect(result.success, isTrue);
    expect(result.photoId, 31);
  });

  test('maps auth error to relogin message', () async {
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
      () => dataSource.saveVisitorPhoto(
        accessToken: 'token',
        request: const VisitorSavePhotoRequestDto(
          imageBase64: 'abc',
          photoDescription: '',
          invitationId: 'IV20260300016',
          entity: 'AGYTEK',
          site: 'FACTORY1',
          uploadedBy: 'Ryan',
        ),
      ),
      throwsA(
        isA<VisitorAccessException>().having(
          (e) => e.message,
          'message',
          'Please login again to upload photo.',
        ),
      ),
    );
  });
}
