import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/get_visitor_lookup_usecase.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  String? capturedCode;
  bool? capturedCheckIn;

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    capturedCode = code;
    capturedCheckIn = isCheckIn;
    return const VisitorLookupEntity(
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
      visitors: [
        VisitorLookupItemEntity(
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

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) async {
    return null;
  }
}

void main() {
  test('forwards parameters to repository', () async {
    final repository = _FakeVisitorAccessRepository();
    final useCase = GetVisitorLookupUseCase(repository);

    final result = await useCase(
      code: 'VIS|IV1|AGYTEK|FACTORY1',
      isCheckIn: true,
    );

    expect(repository.capturedCode, 'VIS|IV1|AGYTEK|FACTORY1');
    expect(repository.capturedCheckIn, isTrue);
    expect(result.invitationId, 'IV1');
  });
}
