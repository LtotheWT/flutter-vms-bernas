import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/invitation_list_item_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_listing_filter_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/invitation_repository.dart';
import 'package:vms_bernas/domain/usecases/submit_invitation_usecase.dart';
import 'package:vms_bernas/presentation/state/invitation_add_providers.dart';

class _FakeInvitationRepository implements InvitationRepository {
  _FakeInvitationRepository(this.response);

  final InvitationSubmissionEntity response;

  @override
  Future<List<InvitationListItemEntity>> listInvitations({
    required InvitationListingFilterEntity filter,
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
  }) async {
    return response;
  }
}

void main() {
  test('submit maps encryptUrl and invitationId from entity', () async {
    final repo = _FakeInvitationRepository(
      const InvitationSubmissionEntity(
        status: true,
        message: 'Invitation submitted.',
        invitationId: 'IV20260300033',
        encryptUrl: 'https://example.com/encrypted',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        submitInvitationUseCaseProvider.overrideWithValue(
          SubmitInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(invitationAddControllerProvider.notifier)
        .submit();

    expect(result.success, isTrue);
    expect(result.message, 'Invitation submitted.');
    expect(result.invitationId, 'IV20260300033');
    expect(result.encryptUrl, 'https://example.com/encrypted');
  });

  test('submit failure keeps backward compatible fields', () async {
    final repo = _FakeInvitationRepository(
      const InvitationSubmissionEntity(status: false, message: 'Failed'),
    );
    final container = ProviderContainer(
      overrides: [
        submitInvitationUseCaseProvider.overrideWithValue(
          SubmitInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(invitationAddControllerProvider.notifier)
        .submit();

    expect(result.success, isFalse);
    expect(result.message, 'Failed');
    expect(result.invitationId, isNull);
    expect(result.encryptUrl, isNull);
  });
}
