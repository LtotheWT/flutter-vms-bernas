import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/permanent_contractor_submit_request_dto.dart';
import 'package:vms_bernas/data/models/permanent_contractor_submit_response_dto.dart';
import 'package:vms_bernas/data/repositories/reference_repository_impl.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_entity.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeReferenceRemoteDataSource extends ReferenceRemoteDataSource {
  _FakeReferenceRemoteDataSource(this.responseDto) : super(Dio());

  final PermanentContractorSubmitResponseDto responseDto;
  String? capturedAccessToken;
  String? capturedIdempotencyKey;
  PermanentContractorSubmitRequestDto? capturedRequest;

  @override
  Future<PermanentContractorSubmitResponseDto>
  submitPermanentContractorCheckIn({
    required String accessToken,
    required String idempotencyKey,
    required PermanentContractorSubmitRequestDto request,
  }) async {
    capturedAccessToken = accessToken;
    capturedIdempotencyKey = idempotencyKey;
    capturedRequest = request;
    return responseDto;
  }
}

void main() {
  test('throws when auth token is missing', () async {
    final repository = ReferenceRepositoryImpl(
      _FakeReferenceRemoteDataSource(
        const PermanentContractorSubmitResponseDto(status: true, message: 'ok'),
      ),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.submitPermanentContractorCheckIn(
        submission: const PermanentContractorSubmitEntity(
          contractorId: 'C0023',
          site: 'FACTORY1',
          gate: 'F1_A',
          createdBy: 'Ryan',
        ),
        idempotencyKey: 'idem-1',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('forwards request and maps success result', () async {
    final remote = _FakeReferenceRemoteDataSource(
      const PermanentContractorSubmitResponseDto(
        status: true,
        message: 'Checked-in successfully.',
      ),
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

    final result = await repository.submitPermanentContractorCheckIn(
      submission: const PermanentContractorSubmitEntity(
        contractorId: 'C0023',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
      idempotencyKey: 'idem-1',
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedIdempotencyKey, 'idem-1');
    expect(remote.capturedRequest?.contractorId, 'C0023');
    expect(result.status, isTrue);
    expect(result.message, 'Checked-in successfully.');
  });
}
