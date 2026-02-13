import '../entities/invitation_submission_entity.dart';
import '../repositories/invitation_repository.dart';

class SubmitInvitationUseCase {
  const SubmitInvitationUseCase(this._repository);

  final InvitationRepository _repository;

  Future<InvitationSubmissionEntity> call({
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
  }) {
    return _repository.submitInvitation(
      idempotencyKey: idempotencyKey,
      entity: entity,
      site: site,
      department: department,
      employeeId: employeeId,
      visitorType: visitorType,
      visitorName: visitorName,
      purpose: purpose,
      email: email,
      visitFrom: visitFrom,
      visitTo: visitTo,
    );
  }
}
