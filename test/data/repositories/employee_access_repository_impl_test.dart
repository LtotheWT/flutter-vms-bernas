import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/employee_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/employee_delete_photo_response_dto.dart';
import 'package:vms_bernas/data/models/employee_gallery_item_dto.dart';
import 'package:vms_bernas/data/models/employee_info_response_dto.dart';
import 'package:vms_bernas/data/models/employee_save_photo_request_dto.dart';
import 'package:vms_bernas/data/models/employee_save_photo_response_dto.dart';
import 'package:vms_bernas/data/models/employee_submit_request_dto.dart';
import 'package:vms_bernas/data/models/employee_submit_response_dto.dart';
import 'package:vms_bernas/data/repositories/employee_access_repository_impl.dart';
import 'package:vms_bernas/domain/entities/employee_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeEmployeeAccessRemoteDataSource
    extends EmployeeAccessRemoteDataSource {
  _FakeEmployeeAccessRemoteDataSource() : super(Dio());

  String? capturedToken;
  String? capturedCode;
  String? capturedIdempotencyKey;
  EmployeeSubmitRequestDto? capturedSubmitRequest;
  String? capturedImageEmployeeId;
  String? capturedGalleryGuid;
  int? capturedGalleryPhotoId;
  EmployeeSavePhotoRequestDto? capturedSavePhotoRequest;
  int? capturedDeletedPhotoId;

  @override
  Future<EmployeeInfoDto> getEmployeeInfo({
    required String accessToken,
    required String code,
  }) async {
    capturedToken = accessToken;
    capturedCode = code;
    return const EmployeeInfoDto(
      employeeId: 'EMP0001',
      employeeName: 'Suraya',
      site: 'FACTORY1',
      department: 'ADC',
      unit: 'ABC',
      vehicleType: 'CAR',
      handphoneNo: '2',
      telNoExtension: '3',
      effectiveWorkingDate: '2025-11-01T00:00:00',
      lastWorkingDate: '2025-11-30T00:00:00',
    );
  }

  @override
  Future<EmployeeSubmitResponseDto> submitEmployeeCheckIn({
    required String accessToken,
    required String idempotencyKey,
    required EmployeeSubmitRequestDto request,
  }) async {
    capturedToken = accessToken;
    capturedIdempotencyKey = idempotencyKey;
    capturedSubmitRequest = request;
    return const EmployeeSubmitResponseDto(
      status: true,
      message: 'ok',
      eventType: 'IN',
      eventDate: '',
      photoGuid: '',
    );
  }

  @override
  Future<EmployeeSubmitResponseDto> submitEmployeeCheckOut({
    required String accessToken,
    required String idempotencyKey,
    required EmployeeSubmitRequestDto request,
  }) async {
    capturedToken = accessToken;
    capturedIdempotencyKey = idempotencyKey;
    capturedSubmitRequest = request;
    return const EmployeeSubmitResponseDto(
      status: true,
      message: 'ok',
      eventType: 'OUT',
      eventDate: '',
      photoGuid: '',
    );
  }

  @override
  Future<Uint8List?> getEmployeeImage({
    required String accessToken,
    required String employeeId,
  }) async {
    capturedToken = accessToken;
    capturedImageEmployeeId = employeeId;
    return Uint8List.fromList(const [1, 2, 3]);
  }

  @override
  Future<List<EmployeeGalleryItemDto>> getEmployeeGalleryList({
    required String accessToken,
    required String guid,
  }) async {
    capturedToken = accessToken;
    capturedGalleryGuid = guid;
    return const [
      EmployeeGalleryItemDto(
        photoId: 40,
        photoDesc: 'Gate',
        url: '/Employee/photo/40',
      ),
    ];
  }

  @override
  Future<Uint8List?> getEmployeeGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedToken = accessToken;
    capturedGalleryPhotoId = photoId;
    return Uint8List.fromList(const [4, 5, 6]);
  }

  @override
  Future<EmployeeSavePhotoResponseDto> saveEmployeePhoto({
    required String accessToken,
    required EmployeeSavePhotoRequestDto request,
  }) async {
    capturedToken = accessToken;
    capturedSavePhotoRequest = request;
    return const EmployeeSavePhotoResponseDto(
      success: true,
      message: 'Photo saved successfully',
      photoId: 40,
    );
  }

  @override
  Future<EmployeeDeletePhotoResponseDto> deleteEmployeeGalleryPhoto({
    required String accessToken,
    required int photoId,
  }) async {
    capturedToken = accessToken;
    capturedDeletedPhotoId = photoId;
    return const EmployeeDeletePhotoResponseDto(
      status: true,
      message: 'delete is successful',
    );
  }
}

void main() {
  test('throws when token is missing', () async {
    final repository = EmployeeAccessRepositoryImpl(
      _FakeEmployeeAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.getEmployeeInfo(code: 'EMP|EMP0001||'),
      throwsA(isA<Exception>()),
    );
  });

  test('maps lookup response from remote', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final result = await repository.getEmployeeInfo(code: 'EMP|EMP0001||');

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedCode, 'EMP|EMP0001||');
    expect(result.employeeId, 'EMP0001');
    expect(result.employeeName, 'Suraya');
  });

  test('maps employee image from remote', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final image = await repository.getEmployeeImage(employeeId: 'EMP0001');

    expect(image, isNotNull);
    expect(remote.capturedToken, 'token123');
    expect(remote.capturedImageEmployeeId, 'EMP0001');
  });

  test('maps submit check-in request and response', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final result = await repository.submitEmployeeCheckIn(
      submission: const EmployeeSubmitEntity(
        employeeId: 'EMP0001',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
      idempotencyKey: 'idem-1',
    );

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedIdempotencyKey, 'idem-1');
    expect(remote.capturedSubmitRequest?.employeeId, 'EMP0001');
    expect(result.status, isTrue);
    expect(result.eventType, 'IN');
  });

  test('submit check-out throws when token missing', () async {
    final repository = EmployeeAccessRepositoryImpl(
      _FakeEmployeeAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.submitEmployeeCheckOut(
        submission: const EmployeeSubmitEntity(
          employeeId: 'EMP0001',
          site: 'FACTORY1',
          gate: 'F1_A',
          createdBy: 'Ryan',
        ),
        idempotencyKey: 'idem-2',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('maps submit check-out request and response', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final result = await repository.submitEmployeeCheckOut(
      submission: const EmployeeSubmitEntity(
        employeeId: 'EMP0001',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
      idempotencyKey: 'idem-3',
    );

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedIdempotencyKey, 'idem-3');
    expect(remote.capturedSubmitRequest?.employeeId, 'EMP0001');
    expect(result.status, isTrue);
    expect(result.eventType, 'OUT');
  });

  test('maps employee gallery list from remote', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final result = await repository.getEmployeeGalleryList(guid: 'guid-1');

    expect(remote.capturedToken, 'token123');
    expect(remote.capturedGalleryGuid, 'guid-1');
    expect(result.single.photoId, 40);
  });

  test('maps employee gallery photo from remote', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final image = await repository.getEmployeeGalleryPhoto(photoId: 40);

    expect(image, isNotNull);
    expect(remote.capturedGalleryPhotoId, 40);
  });

  test('maps save employee photo request and response', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final result = await repository.saveEmployeePhoto(
      submission: const EmployeeSavePhotoSubmissionEntity(
        imageBase64: 'abc',
        photoDescription: 'Gate',
        guid: 'guid-1',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(remote.capturedSavePhotoRequest?.guid, 'guid-1');
    expect(result.success, isTrue);
    expect(result.photoId, 40);
  });

  test('maps delete employee photo response', () async {
    final remote = _FakeEmployeeAccessRemoteDataSource();
    final repository = EmployeeAccessRepositoryImpl(
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

    final result = await repository.deleteEmployeeGalleryPhoto(photoId: 30);

    expect(remote.capturedDeletedPhotoId, 30);
    expect(result.success, isTrue);
  });
}
