import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/reference_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/dashboard_summary_response_dto.dart';
import 'package:vms_bernas/data/repositories/reference_repository_impl.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeReferenceRemoteDataSource extends ReferenceRemoteDataSource {
  _FakeReferenceRemoteDataSource() : super(Dio());

  String? capturedAccessToken;
  String? capturedEntity;

  @override
  Future<DashboardSummaryResponseDto> getDashboardSummary({
    required String accessToken,
    required String entity,
  }) async {
    capturedAccessToken = accessToken;
    capturedEntity = entity;
    return DashboardSummaryResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {
        'VisitorIO': [
          {
            'Entity': 'AGYTEK',
            'TotalInRecords': 839,
            'TotalOutRecords': 661,
            'StillInCount': 178,
          },
        ],
        'ContrIO': [
          {
            'Entity': 'AGYTEK',
            'TotalInRecords': 36,
            'TotalOutRecords': 30,
            'StillInCount': 6,
          },
        ],
        'WhitelistIO': [
          {
            'Entity': 'AGYTEK',
            'TotalInRecords': 38,
            'TotalOutRecords': 38,
            'StillInCount': 0,
          },
        ],
      },
    }, requestedEntity: entity);
  }
}

void main() {
  test('throws when auth token is missing', () async {
    final repository = ReferenceRepositoryImpl(
      _FakeReferenceRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.getDashboardSummary(entity: 'AGYTEK'),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'maps dashboard summary and forwards params when session exists',
    () async {
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

      final summary = await repository.getDashboardSummary(entity: 'AGYTEK');

      expect(remote.capturedAccessToken, 'token123');
      expect(remote.capturedEntity, 'AGYTEK');
      expect(summary.visitor.totalInRecords, 839);
      expect(summary.contractor.stillInCount, 6);
    },
  );
}
