import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/whitelist_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/whitelist_delete_photo_response_dto.dart';
import 'package:vms_bernas/data/models/whitelist_detail_response_dto.dart';
import 'package:vms_bernas/data/models/whitelist_gallery_item_dto.dart';
import 'package:vms_bernas/data/models/whitelist_search_item_dto.dart';
import 'package:vms_bernas/data/models/whitelist_search_request_dto.dart';
import 'package:vms_bernas/data/models/whitelist_save_photo_request_dto.dart';
import 'package:vms_bernas/data/models/whitelist_save_photo_response_dto.dart';
import 'package:vms_bernas/data/models/whitelist_submit_request_dto.dart';
import 'package:vms_bernas/data/models/whitelist_submit_response_dto.dart';
import 'package:vms_bernas/data/repositories/whitelist_repository_impl.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_entity.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeWhitelistRemoteDataSource extends WhitelistRemoteDataSource {
  _FakeWhitelistRemoteDataSource() : super(Dio());

  String? capturedToken;
  WhitelistSearchRequestDto? capturedRequest;
  String? capturedDetailEntity;
  String? capturedDetailVehiclePlate;
  String? capturedIdempotencyKey;
  WhitelistSubmitRequestDto? capturedSubmitRequest;
  String? capturedGalleryGuid;
  int? capturedPhotoId;
  WhitelistSavePhotoRequestDto? capturedSavePhotoRequest;

  @override
  Future<List<WhitelistSearchItemDto>> searchWhitelist({
    required String accessToken,
    required WhitelistSearchRequestDto request,
  }) async {
    capturedToken = accessToken;
    capturedRequest = request;
    return const [
      WhitelistSearchItemDto(
        entity: 'AGYTEK',
        vehiclePlate: 'RYAN1234',
        ic: 'RYAN',
        name: 'RYAN1234',
        status: 'ACTIVE',
        createBy: 'ryan',
        createDate: '2026-01-13 11:46:40',
        updateBy: '',
        updateDate: '',
      ),
    ];
  }

  @override
  Future<WhitelistDetailResponseDto> getWhitelistDetail({
    required String accessToken,
    required String entity,
    required String vehiclePlate,
  }) async {
    capturedToken = accessToken;
    capturedDetailEntity = entity;
    capturedDetailVehiclePlate = vehiclePlate;
    return WhitelistDetailResponseDto(
      status: true,
      message: 'ok',
      details: const WhitelistDetailDto(
        entity: 'AGYTEK',
        vehiclePlate: 'RYAN1234',
        ic: 'RYAN',
        name: 'Ryan Name',
        status: 'ACTIVE',
        createBy: 'admin',
        createDate: '2026-01-13 11:46:40',
        updateBy: 'admin',
        updateDate: '2026-01-13 11:46:40',
      ),
    );
  }

  @override
  Future<WhitelistSubmitResponseDto> submitWhitelistCheckIn({
    required String accessToken,
    required String idempotencyKey,
    required WhitelistSubmitRequestDto request,
  }) async {
    capturedToken = accessToken;
    capturedIdempotencyKey = idempotencyKey;
    capturedSubmitRequest = request;
    return const WhitelistSubmitResponseDto(
      status: true,
      message: 'Whitelist checked IN successfully.',
    );
  }

  @override
  Future<WhitelistSubmitResponseDto> submitWhitelistCheckOut({
    required String accessToken,
    required String idempotencyKey,
    required WhitelistSubmitRequestDto request,
  }) async {
    capturedToken = accessToken;
    capturedIdempotencyKey = idempotencyKey;
    capturedSubmitRequest = request;
    return const WhitelistSubmitResponseDto(
      status: true,
      message: 'Whitelist checked OUT successfully.',
    );
  }

  @override
  Future<List<WhitelistGalleryItemDto>> getWhitelistGalleryList({
    required String accessToken,
    required String guid,
  }) async {
    capturedToken = accessToken;
    capturedGalleryGuid = guid;
    return const [
      WhitelistGalleryItemDto(
        photoId: 31,
        photoDesc: 'test',
        url: '/Whitelist/photo/31',
      ),
    ];
  }

  @override
  Future<Uint8List?> getWhitelistPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedToken = accessToken;
    capturedPhotoId = photoId;
    return Uint8List.fromList(const [1, 2, 3]);
  }

  @override
  Future<WhitelistSavePhotoResponseDto> saveWhitelistPhoto({
    required String accessToken,
    required WhitelistSavePhotoRequestDto request,
  }) async {
    capturedToken = accessToken;
    capturedSavePhotoRequest = request;
    return const WhitelistSavePhotoResponseDto(
      success: true,
      message: 'Photo saved successfully',
      photoId: 31,
    );
  }

  @override
  Future<WhitelistDeletePhotoResponseDto> deleteWhitelistPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedToken = accessToken;
    capturedPhotoId = photoId;
    return const WhitelistDeletePhotoResponseDto(
      status: true,
      message: 'delete is successful',
    );
  }
}

void main() {
  test('throws when token is missing', () async {
    final repository = WhitelistRepositoryImpl(
      _FakeWhitelistRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.searchWhitelist(
        filter: const WhitelistSearchFilterEntity(
          entity: 'AGYTEK',
          currentType: 'I',
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('maps remote whitelist list to entities', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final result = await repository.searchWhitelist(
      filter: const WhitelistSearchFilterEntity(
        entity: 'AGYTEK',
        currentType: 'O',
      ),
    );

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedRequest?.currentType, 'O');
    expect(result, hasLength(1));
    expect(result.first.status, 'ACTIVE');
  });

  test('maps whitelist detail from remote', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final detail = await repository.getWhitelistDetail(
      entity: 'AGYTEK',
      vehiclePlate: 'RYAN1234',
    );

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedDetailEntity, 'AGYTEK');
    expect(remote.capturedDetailVehiclePlate, 'RYAN1234');
    expect(detail.name, 'Ryan Name');
    expect(detail.status, 'ACTIVE');
  });

  test('submit check-in maps request and response', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final result = await repository.submitWhitelistCheckIn(
      submission: const WhitelistSubmitEntity(
        entity: 'AGYTEK',
        site: 'FACTORY1',
        gate: 'F1_A',
        vehiclePlate: 'RYAN1234',
        createdBy: 'Ryan',
      ),
      idempotencyKey: 'idem-1',
    );

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedIdempotencyKey, 'idem-1');
    expect(remote.capturedSubmitRequest?.vehiclePlate, 'RYAN1234');
    expect(result.status, isTrue);
  });

  test('submit check-out throws when token missing', () async {
    final repository = WhitelistRepositoryImpl(
      _FakeWhitelistRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.submitWhitelistCheckOut(
        submission: const WhitelistSubmitEntity(
          entity: 'AGYTEK',
          site: 'FACTORY1',
          gate: 'F1_A',
          vehiclePlate: 'RYAN1234',
          createdBy: 'Ryan',
        ),
        idempotencyKey: 'idem-2',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('submit check-out maps request and response', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final result = await repository.submitWhitelistCheckOut(
      submission: const WhitelistSubmitEntity(
        entity: 'AGYTEK',
        site: 'FACTORY1',
        gate: 'F1_A',
        vehiclePlate: 'RYAN1234',
        createdBy: 'Ryan',
      ),
      idempotencyKey: 'idem-3',
    );

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedIdempotencyKey, 'idem-3');
    expect(remote.capturedSubmitRequest?.vehiclePlate, 'RYAN1234');
    expect(result.status, isTrue);
  });

  test('maps whitelist gallery list from remote', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final result = await repository.getWhitelistGalleryList(guid: 'guid-123');

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedGalleryGuid, 'guid-123');
    expect(result, hasLength(1));
    expect(
      result.first,
      const WhitelistGalleryItemEntity(
        photoId: 31,
        photoDesc: 'test',
        url: '/Whitelist/photo/31',
      ),
    );
  });

  test('maps whitelist photo bytes from remote', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final result = await repository.getWhitelistPhoto(photoId: 31);

    expect(remote.capturedPhotoId, 31);
    expect(result, Uint8List.fromList(const [1, 2, 3]));
  });

  test('save whitelist photo maps request and response', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final result = await repository.saveWhitelistPhoto(
      submission: const WhitelistSavePhotoSubmissionEntity(
        imageBase64: 'abc',
        photoDescription: 'Gate',
        guid: 'guid-123',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(remote.capturedSavePhotoRequest?.guid, 'guid-123');
    expect(result.success, isTrue);
    expect(result.photoId, 31);
  });

  test('delete whitelist photo maps response', () async {
    final remote = _FakeWhitelistRemoteDataSource();
    final repository = WhitelistRepositoryImpl(
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

    final result = await repository.deleteWhitelistPhoto(photoId: 31);

    expect(remote.capturedPhotoId, 31);
    expect(result.success, isTrue);
    expect(result.message, 'delete is successful');
  });
}
