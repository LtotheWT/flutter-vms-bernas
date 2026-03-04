import 'dart:typed_data';

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
import 'package:vms_bernas/domain/usecases/submit_permanent_contractor_check_out_usecase.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  PermanentContractorSubmitEntity? submission;
  String? idempotencyKey;

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    this.submission = submission;
    this.idempotencyKey = idempotencyKey;
    return const PermanentContractorSubmitResultEntity(
      status: true,
      message: 'Checked-out successfully.',
    );
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
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) async {
    return null;
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
}

void main() {
  test('forwards submission and idempotency key', () async {
    final repository = _FakeReferenceRepository();
    final useCase = SubmitPermanentContractorCheckOutUseCase(repository);
    const submission = PermanentContractorSubmitEntity(
      contractorId: 'C0023',
      site: 'FACTORY1',
      gate: 'F1_A',
      createdBy: 'Ryan',
    );

    final result = await useCase(
      submission: submission,
      idempotencyKey: 'idem-2',
    );

    expect(repository.submission, submission);
    expect(repository.idempotencyKey, 'idem-2');
    expect(result.status, isTrue);
  });
}
