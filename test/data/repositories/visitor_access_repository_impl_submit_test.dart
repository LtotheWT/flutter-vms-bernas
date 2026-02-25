import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/visitor_check_in_request_dto.dart';
import 'package:vms_bernas/data/models/visitor_check_in_response_dto.dart';
import 'package:vms_bernas/data/models/visitor_lookup_dto.dart';
import 'package:vms_bernas/data/repositories/visitor_access_repository_impl.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_item_entity.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeVisitorAccessRemoteDataSource extends VisitorAccessRemoteDataSource {
  _FakeVisitorAccessRemoteDataSource() : super(Dio());

  String? capturedAccessToken;
  VisitorCheckInRequestDto? capturedCheckInRequest;
  VisitorCheckInRequestDto? capturedCheckOutRequest;

  @override
  Future<VisitorCheckInResponseDto> submitVisitorCheckIn({
    required String accessToken,
    required VisitorCheckInRequestDto request,
  }) async {
    capturedAccessToken = accessToken;
    capturedCheckInRequest = request;
    return const VisitorCheckInResponseDto(
      success: true,
      message: 'Checked-in successfully.',
    );
  }

  @override
  Future<VisitorCheckInResponseDto> submitVisitorCheckOut({
    required String accessToken,
    required VisitorCheckInRequestDto request,
  }) async {
    capturedAccessToken = accessToken;
    capturedCheckOutRequest = request;
    return const VisitorCheckInResponseDto(
      success: true,
      message: 'Checked-out successfully.',
    );
  }

  @override
  Future<VisitorLookupDto> getVisitorLookup({
    required String accessToken,
    required String code,
    required bool isCheckIn,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  const submission = VisitorCheckInSubmissionEntity(
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
  );

  test('throws when auth token missing', () async {
    final repository = VisitorAccessRepositoryImpl(
      _FakeVisitorAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.submitVisitorCheckIn(submission: submission),
      throwsA(isA<Exception>()),
    );
  });

  test('throws for check-out when auth token missing', () async {
    final repository = VisitorAccessRepositoryImpl(
      _FakeVisitorAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.submitVisitorCheckOut(submission: submission),
      throwsA(isA<Exception>()),
    );
  });

  test('maps submit response and forwards payload', () async {
    final remote = _FakeVisitorAccessRemoteDataSource();
    final repository = VisitorAccessRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final result = await repository.submitVisitorCheckIn(
      submission: submission,
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedCheckInRequest?.invitationId, 'IV20260200038');
    expect(result.success, isTrue);
    expect(result.message, 'Checked-in successfully.');
  });

  test('maps check-out submit response and forwards payload', () async {
    final remote = _FakeVisitorAccessRemoteDataSource();
    final repository = VisitorAccessRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final result = await repository.submitVisitorCheckOut(
      submission: submission,
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedCheckOutRequest?.invitationId, 'IV20260200038');
    expect(result.success, isTrue);
    expect(result.message, 'Checked-out successfully.');
  });
}
