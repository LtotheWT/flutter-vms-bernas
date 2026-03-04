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
import 'package:vms_bernas/domain/usecases/get_permanent_contractor_info_usecase.dart';
import 'dart:typed_data';

class _FakeReferenceRepository implements ReferenceRepository {
  String? capturedCode;

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) async {
    capturedCode = code;
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
  Future<DashboardSummaryEntity> getDashboardSummary({
    required String entity,
  }) async {
    throw UnimplementedError();
  }

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
  test(
    'GetPermanentContractorInfoUseCase forwards code to repository',
    () async {
      final repository = _FakeReferenceRepository();
      final useCase = GetPermanentContractorInfoUseCase(repository);

      final result = await useCase(code: 'CON|C0023||');

      expect(repository.capturedCode, 'CON|C0023||');
      expect(result.contractorId, 'C0023');
    },
  );
}
