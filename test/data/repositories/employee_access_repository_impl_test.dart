import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/employee_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/employee_info_response_dto.dart';
import 'package:vms_bernas/data/models/employee_submit_request_dto.dart';
import 'package:vms_bernas/data/models/employee_submit_response_dto.dart';
import 'package:vms_bernas/data/repositories/employee_access_repository_impl.dart';
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
}
