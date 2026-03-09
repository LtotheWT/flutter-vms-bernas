import '../entities/invitation_delete_result_entity.dart';
import '../repositories/invitation_repository.dart';

class CancelInvitationUseCase {
  const CancelInvitationUseCase(this._repository);

  final InvitationRepository _repository;

  Future<InvitationDeleteResultEntity> call({required String invitationId}) {
    return _repository.cancelInvitation(invitationId: invitationId);
  }
}
