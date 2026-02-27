import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:vms_bernas/domain/entities/permanent_contractor_info_entity.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/entities/ref_personel_entity.dart';
import 'package:vms_bernas/domain/entities/ref_visitor_type_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/domain/usecases/get_permanent_contractor_info_usecase.dart';
import 'package:vms_bernas/presentation/state/permanent_contractor_check_providers.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  _FakeReferenceRepository({this.error});

  final Object? error;
  String? capturedCode;

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
}

void main() {
  test('search success clears input and sets info', () async {
    final repo = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [
        getPermanentContractorInfoUseCaseProvider.overrideWithValue(
          GetPermanentContractorInfoUseCase(repo),
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
}
