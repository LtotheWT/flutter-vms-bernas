import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/invitation_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/invitation_create_request_dto.dart';
import 'package:vms_bernas/data/models/invitation_create_response_dto.dart';
import 'package:vms_bernas/data/models/invitation_delete_response_dto.dart';
import 'package:vms_bernas/data/models/invitation_listing_item_dto.dart';
import 'package:vms_bernas/data/models/invitation_listing_request_dto.dart';
import 'package:vms_bernas/data/repositories/invitation_repository_impl.dart';
import 'package:vms_bernas/domain/entities/invitation_listing_filter_entity.dart';

class _FakeInvitationRemoteDataSource extends InvitationRemoteDataSource {
  _FakeInvitationRemoteDataSource() : super(Dio());

  InvitationListingRequestDto? capturedRequest;
  String? capturedDeleteInvitationId;

  @override
  Future<List<InvitationListingItemDto>> listInvitations({
    required String accessToken,
    required InvitationListingRequestDto request,
  }) async {
    capturedRequest = request;
    return const <InvitationListingItemDto>[];
  }

  @override
  Future<InvitationCreateResponseDto> submitInvitation({
    required String accessToken,
    required String idempotencyKey,
    required InvitationCreateRequestDto request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<InvitationDeleteResponseDto> cancelInvitation({
    required String accessToken,
    required String invitationId,
  }) async {
    capturedDeleteInvitationId = invitationId;
    return const InvitationDeleteResponseDto(
      status: true,
      message: 'Visitor deleted successfully',
    );
  }
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

void main() {
  test(
    'listInvitations defaults empty visit dates to today boundaries',
    () async {
      final remote = _FakeInvitationRemoteDataSource();
      final local = _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'ryan',
          fullname: 'Ryan',
          entity: "AGYTEK",
          accessToken: 'token',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      );
      final repository = InvitationRepositoryImpl(remote, local);
      final now = DateTime.now();
      final todayDateText =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await repository.listInvitations(
        filter: const InvitationListingFilterEntity(),
      );

      expect(remote.capturedRequest, isNotNull);
      expect(
        remote.capturedRequest?.visitFrom,
        '${todayDateText}T00:00:00.000Z',
      );
      expect(remote.capturedRequest?.visitTo, '${todayDateText}T23:59:59.999Z');
    },
  );

  test('listInvitations keeps explicit visit dates unchanged', () async {
    final remote = _FakeInvitationRemoteDataSource();
    final local = _FakeAuthLocalDataSource(
      const AuthSessionDto(
        username: 'ryan',
        fullname: 'Ryan',
        entity: "AGYTEK",
        accessToken: 'token',
        defaultSite: 'FACTORY1',
        defaultGate: 'F1_A',
      ),
    );
    final repository = InvitationRepositoryImpl(remote, local);

    await repository.listInvitations(
      filter: const InvitationListingFilterEntity(
        visitDateFrom: '2026-02-01',
        visitDateTo: '2026-02-07',
      ),
    );

    expect(remote.capturedRequest, isNotNull);
    expect(remote.capturedRequest?.visitFrom, '2026-02-01T00:00:00.000Z');
    expect(remote.capturedRequest?.visitTo, '2026-02-07T23:59:59.999Z');
  });

  test('cancelInvitation forwards invitation id and maps result', () async {
    final remote = _FakeInvitationRemoteDataSource();
    final local = _FakeAuthLocalDataSource(
      const AuthSessionDto(
        username: 'ryan',
        fullname: 'Ryan',
        entity: 'AGYTEK',
        accessToken: 'token',
        defaultSite: 'FACTORY1',
        defaultGate: 'F1_A',
      ),
    );
    final repository = InvitationRepositoryImpl(remote, local);

    final result = await repository.cancelInvitation(
      invitationId: 'IV20260300043',
    );

    expect(remote.capturedDeleteInvitationId, 'IV20260300043');
    expect(result.status, isTrue);
    expect(result.message, 'Visitor deleted successfully');
  });
}
