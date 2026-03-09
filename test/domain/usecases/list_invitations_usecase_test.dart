import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/invitation_list_item_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_delete_result_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_listing_filter_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/invitation_repository.dart';
import 'package:vms_bernas/domain/usecases/list_invitations_usecase.dart';

class _FakeInvitationRepository implements InvitationRepository {
  InvitationListingFilterEntity? capturedFilter;

  @override
  Future<List<InvitationListItemEntity>> listInvitations({
    required InvitationListingFilterEntity filter,
  }) async {
    capturedFilter = filter;
    return const [
      InvitationListItemEntity(
        invitationId: 'IV1',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        department: 'ADC',
        inviteBy: 'EMP0001',
        createdBy: 'admin',
        visitorType: '1_Visitor',
        company: 'ACME',
        vehiclePlateNumber: '',
        statusCode: 'NEW',
        purpose: 'Meeting',
        visitDateFrom: '2026-02-23',
        visitTimeFrom: '07:00:AM',
        visitDateTo: '2026-02-23',
        visitTimeTo: '16:00:PM',
        createDate: '2026-02-22T10:00:00',
        updateDate: '',
        updateBy: '',
      ),
    ];
  }

  @override
  Future<InvitationDeleteResultEntity> cancelInvitation({
    required String invitationId,
  }) {
    throw UnimplementedError();
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
  test('ListInvitationsUseCase forwards filter to repository', () async {
    final repository = _FakeInvitationRepository();
    final useCase = ListInvitationsUseCase(repository);
    const filter = InvitationListingFilterEntity(
      entity: 'AGYTEK',
      site: 'FACTORY1',
      invitationId: 'IV1',
      statusCode: 'NEW',
      upcomingOnly: true,
    );

    final result = await useCase(filter: filter);

    expect(repository.capturedFilter, filter);
    expect(result, hasLength(1));
    expect(result.first.invitationId, 'IV1');
  });
}
