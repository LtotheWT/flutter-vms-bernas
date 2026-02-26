import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/visitor_access_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/visitor_lookup_dto.dart';
import 'package:vms_bernas/data/models/visitor_lookup_item_dto.dart';
import 'package:vms_bernas/data/repositories/visitor_access_repository_impl.dart';

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

class _FakeVisitorAccessRemoteDataSource extends VisitorAccessRemoteDataSource {
  _FakeVisitorAccessRemoteDataSource() : super(Dio());

  String? capturedAccessToken;
  String? capturedCode;
  bool? capturedCheckIn;

  @override
  Future<VisitorLookupDto> getVisitorLookup({
    required String accessToken,
    required String code,
    required bool isCheckIn,
  }) async {
    capturedAccessToken = accessToken;
    capturedCode = code;
    capturedCheckIn = isCheckIn;
    return const VisitorLookupDto(
      invitationId: 'IV1',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      siteDesc: 'FACTORY1 T',
      department: 'ADC',
      departmentDesc: 'ADMIN CENTER',
      purpose: 'MEETING',
      company: 'TEST',
      contactNumber: '0123',
      visitorType: '1_Visitor',
      inviteBy: 'Suraya',
      workLevel: '',
      vehiclePlateNumber: 'WWW0000',
      status: 'ARRIVED',
      visitDateFrom: '2026-02-25T00:00:00',
      visitDateTo: '2026-02-25T00:00:00',
      visitTimeFrom: '19:00:PM',
      visitTimeTo: '20:00:PM',
      visitorList: [
        VisitorLookupItemDto(
          name: 'NAME',
          icPassport: '123',
          physicalTag: '',
          email: '',
          contactNo: '',
          company: '',
          checkInTime: '',
          checkOutTime: '',
        ),
      ],
    );
  }
}

void main() {
  test('throws when auth token missing', () async {
    final repository = VisitorAccessRepositoryImpl(
      _FakeVisitorAccessRemoteDataSource(),
      _FakeAuthLocalDataSource(null),
    );

    expect(
      () => repository.getVisitorLookup(code: 'VIS|IV1|A|F', isCheckIn: true),
      throwsA(isA<Exception>()),
    );
  });

  test('maps remote dto to entity and forwards args', () async {
    final remote = _FakeVisitorAccessRemoteDataSource();
    final repository = VisitorAccessRepositoryImpl(
      remote,
      _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: "AGYTEK",
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      ),
    );

    final result = await repository.getVisitorLookup(
      code: 'VIS|IV1|A|F',
      isCheckIn: false,
    );

    expect(remote.capturedAccessToken, 'token123');
    expect(remote.capturedCode, 'VIS|IV1|A|F');
    expect(remote.capturedCheckIn, isFalse);
    expect(result.invitationId, 'IV1');
    expect(result.visitors, hasLength(1));
  });
}
