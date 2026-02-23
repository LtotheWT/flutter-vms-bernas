import '../entities/invitation_list_item_entity.dart';
import '../entities/invitation_listing_filter_entity.dart';
import '../entities/invitation_submission_entity.dart';

abstract class InvitationRepository {
  Future<List<InvitationListItemEntity>> listInvitations({
    required InvitationListingFilterEntity filter,
  });

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
  });
}
