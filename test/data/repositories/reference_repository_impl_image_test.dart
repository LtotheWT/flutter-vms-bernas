import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/repositories/reference_repository_impl.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeReferenceRemoteDataSource extends ReferenceRemoteDataSource {
  _FakeReferenceRemoteDataSource(this.imageResult) : super(Dio());

  final Uint8List? imageResult;
  String? capturedAccessToken;
  String? capturedContractorId;

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String accessToken,
    required String contractorId,
  }) async {
    capturedAccessToken = accessToken;
    capturedContractorId = contractorId;
    return imageResult;
  }
}

void main() {
  test('throws when auth token is missing', () async {
    final repository = ReferenceRepositoryImpl(
      _FakeReferenceRemoteDataSource(null),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.getPermanentContractorImage(contractorId: 'C0023'),
      throwsA(isA<Exception>()),
    );
  });

  test('returns bytes and forwards params when session exists', () async {
    final remote = _FakeReferenceRemoteDataSource(
      Uint8List.fromList([1, 2, 3]),
    );
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

    final bytes = await repository.getPermanentContractorImage(
      contractorId: 'C0023',
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedContractorId, 'C0023');
    expect(bytes, [1, 2, 3]);
  });
}
