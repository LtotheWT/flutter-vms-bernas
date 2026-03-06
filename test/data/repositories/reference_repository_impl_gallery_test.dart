import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/permanent_contractor_delete_photo_response_dto.dart';
import 'package:vms_bernas/data/models/permanent_contractor_gallery_item_dto.dart';
import 'package:vms_bernas/data/models/permanent_contractor_save_photo_request_dto.dart';
import 'package:vms_bernas/data/models/permanent_contractor_save_photo_response_dto.dart';
import 'package:vms_bernas/data/repositories/reference_repository_impl.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_save_photo_submission_entity.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeReferenceRemoteDataSource extends ReferenceRemoteDataSource {
  _FakeReferenceRemoteDataSource() : super(Dio());

  String? capturedAccessToken;
  String? capturedGuid;
  int? capturedPhotoId;
  PermanentContractorSavePhotoRequestDto? capturedRequest;

  @override
  Future<List<PermanentContractorGalleryItemDto>>
  getPermanentContractorGalleryList({
    required String accessToken,
    required String guid,
  }) async {
    capturedAccessToken = accessToken;
    capturedGuid = guid;
    return const [
      PermanentContractorGalleryItemDto(
        photoId: 53,
        photoDesc: 'string',
        url: '/Contractor/photo/53',
      ),
    ];
  }

  @override
  Future<Uint8List?> getPermanentContractorGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedAccessToken = accessToken;
    capturedPhotoId = photoId;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<PermanentContractorSavePhotoResponseDto> savePermanentContractorPhoto({
    required String accessToken,
    required PermanentContractorSavePhotoRequestDto request,
  }) async {
    capturedAccessToken = accessToken;
    capturedRequest = request;
    return const PermanentContractorSavePhotoResponseDto(
      success: true,
      message: 'Photo saved successfully',
      photoId: 53,
    );
  }

  @override
  Future<PermanentContractorDeletePhotoResponseDto>
  deletePermanentContractorGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedAccessToken = accessToken;
    capturedPhotoId = photoId;
    return const PermanentContractorDeletePhotoResponseDto(
      status: true,
      message: 'delete is successful',
    );
  }
}

void main() {
  test('forwards contractor gallery list request and maps items', () async {
    final remote = _FakeReferenceRemoteDataSource();
    final repository = ReferenceRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: 'AGYTEK',
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final items = await repository.getPermanentContractorGalleryList(
      guid: 'guid-1',
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedGuid, 'guid-1');
    expect(items.single.photoId, 53);
  });

  test('forwards contractor save photo request and maps result', () async {
    final remote = _FakeReferenceRemoteDataSource();
    final repository = ReferenceRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: 'AGYTEK',
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final result = await repository.savePermanentContractorPhoto(
      submission: const PermanentContractorSavePhotoSubmissionEntity(
        imageBase64: 'abc',
        photoDescription: 'Gate shot',
        guid: 'guid-1',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(remote.capturedRequest?.guid, 'guid-1');
    expect(result.success, isTrue);
    expect(result.photoId, 53);
  });
}
