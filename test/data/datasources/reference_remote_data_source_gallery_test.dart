import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';
import 'package:vms_bernas/data/models/permanent_contractor_save_photo_request_dto.dart';

void main() {
  test('loads contractor gallery list', () async {
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
                  'photoId': 53,
                  'photoDesc': 'string',
                  'Url': '/Contractor/photo/53',
                },
              ],
            ),
          );
        },
      ),
    );
    final dataSource = ReferenceRemoteDataSource(dio);

    final items = await dataSource.getPermanentContractorGalleryList(
      accessToken: 'token',
      guid: 'guid-1',
    );

    expect(
      capturedUri.toString(),
      contains('/wmsws/Contractor/gallery-list/guid-1'),
    );
    expect(items.single.photoId, 53);
  });

  test('loads contractor gallery photo bytes', () async {
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
    final dataSource = ReferenceRemoteDataSource(dio);

    final bytes = await dataSource.getPermanentContractorGalleryPhoto(
      accessToken: 'token',
      photoId: 53,
    );

    expect(capturedUri.toString(), contains('/wmsws/Contractor/photo/53'));
    expect(bytes, [1, 2, 3]);
  });

  test('posts contractor save photo with expected body', () async {
    final dio = Dio();
    Uri? capturedUri;
    Object? capturedData;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          capturedData = options.data;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {
                'success': true,
                'message': 'Photo saved successfully',
                'data': {'PhotoId': 53},
              },
            ),
          );
        },
      ),
    );
    final dataSource = ReferenceRemoteDataSource(dio);

    final dto = await dataSource.savePermanentContractorPhoto(
      accessToken: 'token',
      request: const PermanentContractorSavePhotoRequestDto(
        imageBase64: 'abc',
        photoDescription: 'Gate shot',
        guid: 'guid-1',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(capturedUri.toString(), contains('/wmsws/Contractor/save-photo'));
    expect(capturedData, {
      'ImageBase64': 'abc',
      'PhotoDescription': 'Gate shot',
      'GUID': 'guid-1',
      'Entity': 'AGYTEK',
      'Site': 'FACTORY1',
      'UploadedBy': 'Ryan',
    });
    expect(dto.photoId, 53);
  });

  test('deletes contractor photo', () async {
    final dio = Dio();
    Uri? capturedUri;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUri = options.uri;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: {'Status': true, 'Message': 'delete is successful'},
            ),
          );
        },
      ),
    );
    final dataSource = ReferenceRemoteDataSource(dio);

    final dto = await dataSource.deletePermanentContractorGalleryPhoto(
      accessToken: 'token',
      photoId: 53,
    );

    expect(
      capturedUri.toString(),
      contains('/wmsws/Contractor/photo/53/delete'),
    );
    expect(dto.status, isTrue);
  });
}
