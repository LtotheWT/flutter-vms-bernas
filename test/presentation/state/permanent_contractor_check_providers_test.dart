import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:vms_bernas/domain/entities/permanent_contractor_info_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_result_entity.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/entities/ref_personel_entity.dart';
import 'package:vms_bernas/domain/entities/ref_visitor_type_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/domain/usecases/get_permanent_contractor_info_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_permanent_contractor_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_permanent_contractor_check_out_usecase.dart';
import 'package:vms_bernas/presentation/state/permanent_contractor_check_providers.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  _FakeReferenceRepository({this.error});

  final Object? error;
  String? capturedCode;
  PermanentContractorSubmitEntity? checkInSubmission;
  PermanentContractorSubmitEntity? checkOutSubmission;
  String? checkInIdempotencyKey;
  String? checkOutIdempotencyKey;

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) async {
    capturedCode = code;
    if (error != null) {
      throw error!;
    }
    return const PermanentContractorInfoEntity(
      contractorId: 'C0023',
      contractorName: 'Dylan Myer',
      contractorIc: '',
      hpNo: '0111111111',
      email: 'angypin8978@gmail.com',
      company: 'MMG (M) SDN BHD',
      validWorkingDateFrom: '2026-01-01T00:00:00',
      validWorkingDateTo: '2026-12-31T00:00:00',
    );
  }

  @override
  Future<List<RefEntityEntity>> getEntities() async => const [];

  @override
  Future<List<RefDepartmentEntity>> getDepartments({
    required String entity,
  }) async => const [];

  @override
  Future<List<RefLocationEntity>> getLocations({
    required String entity,
  }) async => const [];

  @override
  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  }) async => const [];

  @override
  Future<List<RefVisitorTypeEntity>> getVisitorTypes() async => const [];

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) async => null;

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckIn({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    checkInSubmission = submission;
    checkInIdempotencyKey = idempotencyKey;
    return const PermanentContractorSubmitResultEntity(
      status: true,
      message: 'Checked-in successfully.',
    );
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    checkOutSubmission = submission;
    checkOutIdempotencyKey = idempotencyKey;
    return const PermanentContractorSubmitResultEntity(
      status: true,
      message: 'Checked-out successfully.',
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
  test('search success clears input and sets info', () async {
    final repo = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [
        getPermanentContractorInfoUseCaseProvider.overrideWithValue(
          GetPermanentContractorInfoUseCase(repo),
        ),
        submitPermanentContractorCheckInUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckInUseCase(repo),
        ),
        submitPermanentContractorCheckOutUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckOutUseCase(repo),
        ),
        authLocalDataSourceProvider.overrideWithValue(
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
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      permanentContractorCheckControllerProvider.notifier,
    );

    controller.updateSearchInput('CON|C0023||');
    final ok = await controller.search();

    final state = container.read(permanentContractorCheckControllerProvider);
    expect(ok, isTrue);
    expect(repo.capturedCode, 'CON|C0023||');
    expect(state.searchInput, isEmpty);
    expect(state.info?.contractorId, 'C0023');
    expect(state.errorMessage, isNull);
  });

  test('search failure keeps input and sets error', () async {
    final repo = _FakeReferenceRepository(error: Exception('not found'));
    final container = ProviderContainer(
      overrides: [
        getPermanentContractorInfoUseCaseProvider.overrideWithValue(
          GetPermanentContractorInfoUseCase(repo),
        ),
        submitPermanentContractorCheckInUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckInUseCase(repo),
        ),
        submitPermanentContractorCheckOutUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckOutUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      permanentContractorCheckControllerProvider.notifier,
    );

    controller.updateSearchInput('CON|BAD||');
    final ok = await controller.search();

    final state = container.read(permanentContractorCheckControllerProvider);
    expect(ok, isFalse);
    expect(state.searchInput, 'CON|BAD||');
    expect(state.errorMessage, 'not found');
  });

  test('search validates empty input', () async {
    final repo = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [
        getPermanentContractorInfoUseCaseProvider.overrideWithValue(
          GetPermanentContractorInfoUseCase(repo),
        ),
        submitPermanentContractorCheckInUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckInUseCase(repo),
        ),
        submitPermanentContractorCheckOutUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckOutUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      permanentContractorCheckControllerProvider.notifier,
    );

    controller.updateSearchInput('   ');
    final ok = await controller.search();

    expect(ok, isFalse);
    expect(
      container.read(permanentContractorCheckControllerProvider).errorMessage,
      'Please input or scan contractor code.',
    );
  });

  test('submit check-in reuses idempotency key across retries', () async {
    final repo = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [
        submitPermanentContractorCheckInUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckInUseCase(repo),
        ),
        submitPermanentContractorCheckOutUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckOutUseCase(repo),
        ),
        authLocalDataSourceProvider.overrideWithValue(
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
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      permanentContractorCheckControllerProvider.notifier,
    );

    container
        .read(permanentContractorCheckControllerProvider.notifier)
        .state = const PermanentContractorCheckState(
      info: PermanentContractorInfoEntity(
        contractorId: 'C0023',
        contractorName: 'Dylan',
        contractorIc: '',
        hpNo: '',
        email: '',
        company: '',
        validWorkingDateFrom: '',
        validWorkingDateTo: '',
      ),
    );

    await controller.submitCheckIn();
    final firstKey = repo.checkInIdempotencyKey;
    await controller.submitCheckIn();
    final secondKey = repo.checkInIdempotencyKey;

    expect(firstKey, isNotNull);
    expect(secondKey, firstKey);
  });

  test('changing check type resets idempotency key', () async {
    final repo = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [
        submitPermanentContractorCheckInUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckInUseCase(repo),
        ),
        submitPermanentContractorCheckOutUseCaseProvider.overrideWithValue(
          SubmitPermanentContractorCheckOutUseCase(repo),
        ),
        authLocalDataSourceProvider.overrideWithValue(
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
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      permanentContractorCheckControllerProvider.notifier,
    );

    controller.state = const PermanentContractorCheckState(
      checkType: PermanentContractorCheckType.checkIn,
      info: PermanentContractorInfoEntity(
        contractorId: 'C0023',
        contractorName: 'Dylan',
        contractorIc: '',
        hpNo: '',
        email: '',
        company: '',
        validWorkingDateFrom: '',
        validWorkingDateTo: '',
      ),
    );
    await controller.submitCheckIn();
    final keyBeforeChange = container
        .read(permanentContractorCheckControllerProvider)
        .idempotencyKey;
    expect(keyBeforeChange, isNotNull);

    controller.setCheckType(PermanentContractorCheckType.checkOut);
    expect(
      container.read(permanentContractorCheckControllerProvider).idempotencyKey,
      isNull,
    );
  });
}
