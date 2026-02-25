import 'dart:typed_data';

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

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeVisitorAccessRemoteDataSource extends VisitorAccessRemoteDataSource {
  _FakeVisitorAccessRemoteDataSource(this.imageResult) : super(Dio());

  final Uint8List? imageResult;
  String? capturedAccessToken;
  String? capturedInvitationId;
  String? capturedAppId;

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String accessToken,
    required String invitationId,
    required String appId,
  }) async {
    capturedAccessToken = accessToken;
    capturedInvitationId = invitationId;
    capturedAppId = appId;
    return imageResult;
  }

  @override
  Future<VisitorCheckInResponseDto> submitVisitorCheckIn({
    required String accessToken,
    required VisitorCheckInRequestDto request,
  }) async {
    throw UnimplementedError();
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
  test('throws when auth token is missing', () async {
    final repository = VisitorAccessRepositoryImpl(
      _FakeVisitorAccessRemoteDataSource(null),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.getVisitorApplicantImage(
        invitationId: 'IV1',
        appId: 'APP1',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('returns bytes and forwards params when session exists', () async {
    final remote = _FakeVisitorAccessRemoteDataSource(
      Uint8List.fromList([9, 8, 7]),
    );
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

    final bytes = await repository.getVisitorApplicantImage(
      invitationId: 'IV20260200038',
      appId: '12345656123',
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedInvitationId, 'IV20260200038');
    expect(remote.capturedAppId, '12345656123');
    expect(bytes, [9, 8, 7]);
  });
}
