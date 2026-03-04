import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/dashboard_summary_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_info_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_result_entity.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/entities/ref_personel_entity.dart';
import 'package:vms_bernas/domain/entities/ref_visitor_type_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/presentation/state/permanent_contractor_check_providers.dart';
import 'package:vms_bernas/presentation/state/reference_providers.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  int imageCallCount = 0;
  final Map<String, Uint8List?> imageById = <String, Uint8List?>{};

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) async {
    imageCallCount += 1;
    return imageById[contractorId];
  }

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) async {
    throw UnimplementedError();
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
  Future<DashboardSummaryEntity> getDashboardSummary({
    required String entity,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckIn({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  test('returns null without fetch when contractorId is empty', () async {
    final repository = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [referenceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      permanentContractorImageProvider(
        const PermanentContractorPhotoKey(contractorId: ''),
      ).future,
    );

    expect(result, isNull);
    expect(repository.imageCallCount, 0);
  });

  test('uses in-memory cache for same key', () async {
    final repository = _FakeReferenceRepository();
    repository.imageById['C0023'] = Uint8List.fromList([3, 2, 1]);
    final container = ProviderContainer(
      overrides: [referenceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final first = await container.read(
      permanentContractorImageProvider(
        const PermanentContractorPhotoKey(contractorId: 'C0023'),
      ).future,
    );
    container.invalidate(
      permanentContractorImageProvider(
        const PermanentContractorPhotoKey(contractorId: 'C0023'),
      ),
    );
    final second = await container.read(
      permanentContractorImageProvider(
        const PermanentContractorPhotoKey(contractorId: 'C0023'),
      ).future,
    );

    expect(first, [3, 2, 1]);
    expect(second, [3, 2, 1]);
    expect(repository.imageCallCount, 1);
  });

  test('different key triggers another fetch', () async {
    final repository = _FakeReferenceRepository();
    repository.imageById['C0023'] = Uint8List.fromList([1]);
    repository.imageById['C0024'] = Uint8List.fromList([2]);
    final container = ProviderContainer(
      overrides: [referenceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(
      permanentContractorImageProvider(
        const PermanentContractorPhotoKey(contractorId: 'C0023'),
      ).future,
    );
    await container.read(
      permanentContractorImageProvider(
        const PermanentContractorPhotoKey(contractorId: 'C0024'),
      ).future,
    );

    expect(repository.imageCallCount, 2);
  });
}
