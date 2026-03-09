import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_bernas/domain/entities/invitation_delete_result_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_list_item_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_listing_filter_entity.dart';
import 'package:vms_bernas/domain/repositories/invitation_repository.dart';
import 'package:vms_bernas/domain/entities/invitation_submission_entity.dart';
import 'package:vms_bernas/domain/usecases/cancel_invitation_usecase.dart';
import 'package:vms_bernas/domain/usecases/list_invitations_usecase.dart';
import 'package:vms_bernas/presentation/state/invitation_listing_providers.dart';

class _FakeInvitationRepository implements InvitationRepository {
  _FakeInvitationRepository({
    this.shouldThrow = false,
    this.shouldDeleteThrow = false,
    this.items = const <InvitationListItemEntity>[
      InvitationListItemEntity(
        invitationId: 'IV20251200001',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        department: 'ADC',
        inviteBy: 'EMP0001',
        createdBy: 'admin',
        visitorType: '1_Visitor',
        company: 'RUFI TEST 1',
        vehiclePlateNumber: '',
        statusCode: 'NEW',
        purpose: 'RUFI TEST 1',
        visitDateFrom: '2025-12-09',
        visitTimeFrom: '07:00:AM',
        visitDateTo: '2025-12-09',
        visitTimeTo: '16:00:PM',
        createDate: '2025-12-09T01:59:06.877',
        updateDate: '',
        updateBy: '',
      ),
    ],
  });

  final bool shouldThrow;
  final bool shouldDeleteThrow;
  final List<InvitationListItemEntity> items;
  InvitationListingFilterEntity? lastFilter;
  String? lastDeletedInvitationId;

  @override
  Future<List<InvitationListItemEntity>> listInvitations({
    required InvitationListingFilterEntity filter,
  }) async {
    lastFilter = filter;
    if (shouldThrow) {
      throw Exception('boom');
    }

    return items;
  }

  @override
  Future<InvitationDeleteResultEntity> cancelInvitation({
    required String invitationId,
  }) async {
    lastDeletedInvitationId = invitationId;
    if (shouldDeleteThrow) {
      throw Exception('delete boom');
    }
    return const InvitationDeleteResultEntity(
      status: true,
      message: 'Visitor deleted successfully',
    );
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
  test('loadInitial populates items', () async {
    final repo = _FakeInvitationRepository();
    final container = ProviderContainer(
      overrides: [
        listInvitationsUseCaseProvider.overrideWithValue(
          ListInvitationsUseCase(repo),
        ),
        cancelInvitationUseCaseProvider.overrideWithValue(
          CancelInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(invitationListingControllerProvider.notifier)
        .loadInitial();

    final state = container.read(invitationListingControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.hasLoaded, isTrue);
    expect(state.items, hasLength(1));
    expect(repo.lastFilter, const InvitationListingFilterEntity());
  });

  test('applyFilters forwards filter and updates state', () async {
    final repo = _FakeInvitationRepository();
    final container = ProviderContainer(
      overrides: [
        listInvitationsUseCaseProvider.overrideWithValue(
          ListInvitationsUseCase(repo),
        ),
        cancelInvitationUseCaseProvider.overrideWithValue(
          CancelInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    const filter = InvitationListingFilterEntity(
      entity: 'AGYTEK',
      site: 'FACTORY1',
      invitationId: 'IV20251200001',
      statusCode: 'NEW',
    );

    await container
        .read(invitationListingControllerProvider.notifier)
        .applyFilters(filter);

    final state = container.read(invitationListingControllerProvider);
    expect(repo.lastFilter, filter);
    expect(state.items, hasLength(1));
    expect(state.errorMessage, isNull);
  });

  test('fetch failure sets error message', () async {
    final repo = _FakeInvitationRepository(shouldThrow: true);
    final container = ProviderContainer(
      overrides: [
        listInvitationsUseCaseProvider.overrideWithValue(
          ListInvitationsUseCase(repo),
        ),
        cancelInvitationUseCaseProvider.overrideWithValue(
          CancelInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(invitationListingControllerProvider.notifier)
        .loadInitial();

    final state = container.read(invitationListingControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.hasLoaded, isTrue);
    expect(state.errorMessage, 'boom');
  });

  test('items are sorted by createDate desc with invalid dates last', () async {
    final repo = _FakeInvitationRepository(
      items: const [
        InvitationListItemEntity(
          invitationId: 'OLD',
          entity: 'AGYTEK',
          site: 'FACTORY1',
          department: 'ADC',
          inviteBy: 'EMP0001',
          createdBy: 'admin',
          visitorType: '1_Visitor',
          company: 'A',
          vehiclePlateNumber: '',
          statusCode: 'NEW',
          purpose: 'Old',
          visitDateFrom: '2025-12-09',
          visitTimeFrom: '07:00:AM',
          visitDateTo: '2025-12-09',
          visitTimeTo: '16:00:PM',
          createDate: '2025-01-01T00:00:00.000',
          updateDate: '',
          updateBy: '',
        ),
        InvitationListItemEntity(
          invitationId: 'INVALID',
          entity: 'AGYTEK',
          site: 'FACTORY1',
          department: 'ADC',
          inviteBy: 'EMP0001',
          createdBy: 'admin',
          visitorType: '1_Visitor',
          company: 'B',
          vehiclePlateNumber: '',
          statusCode: 'NEW',
          purpose: 'Invalid',
          visitDateFrom: '2025-12-09',
          visitTimeFrom: '07:00:AM',
          visitDateTo: '2025-12-09',
          visitTimeTo: '16:00:PM',
          createDate: 'not-a-date',
          updateDate: '',
          updateBy: '',
        ),
        InvitationListItemEntity(
          invitationId: 'NEWEST',
          entity: 'AGYTEK',
          site: 'FACTORY1',
          department: 'ADC',
          inviteBy: 'EMP0001',
          createdBy: 'admin',
          visitorType: '1_Visitor',
          company: 'C',
          vehiclePlateNumber: '',
          statusCode: 'NEW',
          purpose: 'Newest',
          visitDateFrom: '2025-12-09',
          visitTimeFrom: '07:00:AM',
          visitDateTo: '2025-12-09',
          visitTimeTo: '16:00:PM',
          createDate: '2026-01-01T00:00:00.000',
          updateDate: '',
          updateBy: '',
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        listInvitationsUseCaseProvider.overrideWithValue(
          ListInvitationsUseCase(repo),
        ),
        cancelInvitationUseCaseProvider.overrideWithValue(
          CancelInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(invitationListingControllerProvider.notifier)
        .loadInitial();

    final state = container.read(invitationListingControllerProvider);
    expect(state.items.map((e) => e.invitationId).toList(), [
      'NEWEST',
      'OLD',
      'INVALID',
    ]);
  });

  test('deleteInvitation removes item locally on success', () async {
    final repo = _FakeInvitationRepository();
    final container = ProviderContainer(
      overrides: [
        listInvitationsUseCaseProvider.overrideWithValue(
          ListInvitationsUseCase(repo),
        ),
        cancelInvitationUseCaseProvider.overrideWithValue(
          CancelInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(invitationListingControllerProvider.notifier)
        .loadInitial();
    final result = await container
        .read(invitationListingControllerProvider.notifier)
        .deleteInvitation(invitationId: 'IV20251200001');

    final state = container.read(invitationListingControllerProvider);
    expect(repo.lastDeletedInvitationId, 'IV20251200001');
    expect(result.status, isTrue);
    expect(state.items, isEmpty);
    expect(state.deletingInvitationId, isNull);
  });

  test('deleteInvitation failure keeps items and exposes message', () async {
    final repo = _FakeInvitationRepository(shouldDeleteThrow: true);
    final container = ProviderContainer(
      overrides: [
        listInvitationsUseCaseProvider.overrideWithValue(
          ListInvitationsUseCase(repo),
        ),
        cancelInvitationUseCaseProvider.overrideWithValue(
          CancelInvitationUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(invitationListingControllerProvider.notifier)
        .loadInitial();
    final result = await container
        .read(invitationListingControllerProvider.notifier)
        .deleteInvitation(invitationId: 'IV20251200001');

    final state = container.read(invitationListingControllerProvider);
    expect(result.status, isFalse);
    expect(result.message, 'delete boom');
    expect(state.items, hasLength(1));
    expect(state.deletingInvitationId, isNull);
  });
}
