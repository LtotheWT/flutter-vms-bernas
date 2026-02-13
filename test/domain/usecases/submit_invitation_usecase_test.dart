import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/invitation_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/invitation_repository.dart';
import 'package:vms_bernas/domain/usecases/submit_invitation_usecase.dart';

class _FakeInvitationRepository implements InvitationRepository {
  String? idempotencyKey;
  String? entity;
  String? site;
  String? department;
  String? employeeId;
  String? visitorType;
  String? visitorName;
  String? purpose;
  String? email;
  String? visitFrom;
  String? visitTo;

  @override
  Future<InvitationSubmissionEntity> submitInvitation({
    required String idempotencyKey,
    required String entity,
    required String site,
    required String department,
    required String employeeId,
    required String visitorType,
    required String visitorName,
    required String purpose,
    required String email,
    required String visitFrom,
    required String visitTo,
  }) async {
    this.idempotencyKey = idempotencyKey;
    this.entity = entity;
    this.site = site;
    this.department = department;
    this.employeeId = employeeId;
    this.visitorType = visitorType;
    this.visitorName = visitorName;
    this.purpose = purpose;
    this.email = email;
    this.visitFrom = visitFrom;
    this.visitTo = visitTo;
    return const InvitationSubmissionEntity(status: true, message: null);
  }
}

void main() {
  test('SubmitInvitationUseCase forwards payload to repository', () async {
    final repository = _FakeInvitationRepository();
    final useCase = SubmitInvitationUseCase(repository);

    final result = await useCase(
      idempotencyKey: '11111111-1111-4111-8111-111111111111',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      department: 'ADC',
      employeeId: 'EMP0001',
      visitorType: '1_Visitor',
      visitorName: 'Suraya',
      purpose: 'Meeting',
      email: 'a@b.com',
      visitFrom: '2026-02-13 08:24',
      visitTo: '2026-02-13 09:24',
    );

    expect(repository.idempotencyKey, '11111111-1111-4111-8111-111111111111');
    expect(repository.entity, 'AGYTEK');
    expect(repository.site, 'FACTORY1');
    expect(repository.department, 'ADC');
    expect(repository.employeeId, 'EMP0001');
    expect(repository.visitorType, '1_Visitor');
    expect(repository.visitorName, 'Suraya');
    expect(repository.purpose, 'Meeting');
    expect(repository.email, 'a@b.com');
    expect(repository.visitFrom, '2026-02-13 08:24');
    expect(repository.visitTo, '2026-02-13 09:24');
    expect(result.status, isTrue);
  });
}
