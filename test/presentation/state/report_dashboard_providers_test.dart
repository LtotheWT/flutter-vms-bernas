import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/dashboard_io_metric_entity.dart';
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
import 'package:vms_bernas/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:vms_bernas/presentation/state/report_dashboard_providers.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_save_photo_submission_entity.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  _FakeReferenceRepository({this.shouldThrow = false});

  final bool shouldThrow;
  String? lastEntity;

  @override
  Future<DashboardSummaryEntity> getDashboardSummary({
    required String entity,
  }) async {
    lastEntity = entity;
    if (shouldThrow) {
      throw Exception('dashboard failed');
    }

    return const DashboardSummaryEntity(
      visitor: DashboardIoMetricEntity(
        entity: 'AGYTEK',
        totalInRecords: 839,
        totalOutRecords: 661,
        stillInCount: 178,
      ),
      contractor: DashboardIoMetricEntity(
        entity: 'AGYTEK',
        totalInRecords: 36,
        totalOutRecords: 30,
        stillInCount: 6,
      ),
      whitelist: DashboardIoMetricEntity(
        entity: 'AGYTEK',
        totalInRecords: 38,
        totalOutRecords: 38,
        stillInCount: 0,
      ),
    );
  }

  @override
  Future<List<RefEntityEntity>> getEntities() {
    throw UnimplementedError();
  }

  @override
  Future<List<RefDepartmentEntity>> getDepartments({required String entity}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RefLocationEntity>> getLocations({required String entity}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<RefVisitorTypeEntity>> getVisitorTypes() {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckIn({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<PermanentContractorGalleryItemEntity>>
  getPermanentContractorGalleryList({required String guid}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getPermanentContractorGalleryPhoto({
    required int photoId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorSavePhotoResultEntity>
  savePermanentContractorPhoto({
    required PermanentContractorSavePhotoSubmissionEntity submission,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorDeletePhotoResultEntity>
  deletePermanentContractorGalleryPhoto({required int photoId}) {
    throw UnimplementedError();
  }
}

void main() {
  test('initial load success sets summary and active entity', () async {
    final repository = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [
        getDashboardSummaryUseCaseProvider.overrideWithValue(
          GetDashboardSummaryUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(reportDashboardControllerProvider.notifier)
        .loadInitial(defaultEntity: 'AGYTEK');

    final state = container.read(reportDashboardControllerProvider);
    expect(repository.lastEntity, 'AGYTEK');
    expect(state.summary, isNotNull);
    expect(state.activeEntity, 'AGYTEK');
    expect(state.errorMessage, isNull);
  });

  test('applyEntity refetches with selected entity', () async {
    final repository = _FakeReferenceRepository();
    final container = ProviderContainer(
      overrides: [
        getDashboardSummaryUseCaseProvider.overrideWithValue(
          GetDashboardSummaryUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(reportDashboardControllerProvider.notifier)
        .applyEntity('ABC');

    expect(repository.lastEntity, 'ABC');
    expect(
      container.read(reportDashboardControllerProvider).activeEntity,
      'ABC',
    );
  });

  test('load failure sets error message', () async {
    final repository = _FakeReferenceRepository(shouldThrow: true);
    final container = ProviderContainer(
      overrides: [
        getDashboardSummaryUseCaseProvider.overrideWithValue(
          GetDashboardSummaryUseCase(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(reportDashboardControllerProvider.notifier)
        .loadInitial(defaultEntity: 'AGYTEK');

    final state = container.read(reportDashboardControllerProvider);
    expect(state.errorMessage, 'dashboard failed');
    expect(state.hasLoaded, isTrue);
  });
}
