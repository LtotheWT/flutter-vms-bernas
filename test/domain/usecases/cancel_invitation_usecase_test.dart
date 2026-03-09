import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/invitation_delete_result_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_list_item_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_listing_filter_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/invitation_repository.dart';
import 'package:vms_bernas/domain/usecases/cancel_invitation_usecase.dart';

class _FakeInvitationRepository implements InvitationRepository {
  String? cancelledInvitationId;

  @override
  Future<InvitationDeleteResultEntity> cancelInvitation({
    required String invitationId,
  }) async {
    cancelledInvitationId = invitationId;
    return const InvitationDeleteResultEntity(
      status: true,
      message: 'Visitor deleted successfully',
    );
  }

  @override
  Future<List<InvitationListItemEntity>> listInvitations({
    required InvitationListingFilterEntity filter,
  }) async {
    return const <InvitationListItemEntity>[];
  }

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
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test(
    'CancelInvitationUseCase forwards invitation id to repository',
    () async {
      final repository = _FakeInvitationRepository();
      final useCase = CancelInvitationUseCase(repository);

      final result = await useCase(invitationId: 'IV20260300043');

      expect(repository.cancelledInvitationId, 'IV20260300043');
      expect(result.status, isTrue);
    },
  );
}
