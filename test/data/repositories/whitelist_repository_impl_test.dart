import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/datasources/whitelist_remote_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/data/models/whitelist_detail_response_dto.dart';
import 'package:vms_bernas/data/models/whitelist_search_item_dto.dart';
import 'package:vms_bernas/data/models/whitelist_search_request_dto.dart';
import 'package:vms_bernas/data/models/whitelist_submit_request_dto.dart';
import 'package:vms_bernas/data/models/whitelist_submit_response_dto.dart';
import 'package:vms_bernas/data/repositories/whitelist_repository_impl.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
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
}
