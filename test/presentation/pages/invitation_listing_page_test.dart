import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/invitation_delete_result_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_list_item_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_listing_filter_entity.dart';
import 'package:vms_bernas/domain/entities/invitation_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/invitation_repository.dart';
import 'package:vms_bernas/domain/usecases/cancel_invitation_usecase.dart';
import 'package:vms_bernas/domain/usecases/list_invitations_usecase.dart';
import 'package:vms_bernas/presentation/pages/invitation_listing_page.dart';
import 'package:vms_bernas/presentation/state/invitation_listing_providers.dart';

class _FakeInvitationRepository implements InvitationRepository {
  _FakeInvitationRepository({this.deleteShouldFail = false});

  final bool deleteShouldFail;
  int listCallCount = 0;

  @override
  Future<InvitationDeleteResultEntity> cancelInvitation({
    required String invitationId,
  }) async {
    if (deleteShouldFail) {
      throw Exception('Delete failed');
    }
    return const InvitationDeleteResultEntity(
      status: true,
      message: 'Visitor deleted successfully',
    );
  }

  @override
  Future<List<InvitationListItemEntity>> listInvitations({
    required InvitationListingFilterEntity filter,
  }) async {
    listCallCount += 1;
    return const <InvitationListItemEntity>[
      InvitationListItemEntity(
        invitationId: 'IV20260300043',
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
        visitDateFrom: '2026-03-10',
        visitTimeFrom: '07:00:AM',
        visitDateTo: '2026-03-10',
        visitTimeTo: '16:00:PM',
        createDate: '2026-03-10T10:00:00',
        updateDate: '',
        updateBy: '',
      ),
    ];
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

Widget _buildApp(_FakeInvitationRepository repository) {
  return ProviderScope(
    overrides: [
      listInvitationsUseCaseProvider.overrideWithValue(
        ListInvitationsUseCase(repository),
      ),
      cancelInvitationUseCaseProvider.overrideWithValue(
        CancelInvitationUseCase(repository),
      ),
    ],
    child: const MaterialApp(home: InvitationListingPage()),
  );
}

void main() {
  testWidgets('bulk selection UI removed and per-row delete shown', (
    tester,
  ) async {
    final repository = _FakeInvitationRepository();
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('Select all'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(
      find.byKey(const Key('invitation-delete-IV20260300043')),
      findsOneWidget,
    );
  });

  testWidgets('delete success removes row locally and shows snackbar', (
    tester,
  ) async {
    final repository = _FakeInvitationRepository();
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('invitation-delete-IV20260300043')));
    await tester.pumpAndSettle();
    expect(find.text('Delete invitation?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Visitor deleted successfully'), findsOneWidget);
    expect(find.text('IV20260300043'), findsNothing);
  });

  testWidgets('delete failure keeps row and shows snackbar', (tester) async {
    final repository = _FakeInvitationRepository(deleteShouldFail: true);
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('invitation-delete-IV20260300043')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete failed'), findsWidgets);
    expect(find.text('IV20260300043'), findsOneWidget);
  });

  testWidgets('pull to refresh reloads current listing', (tester) async {
    final repository = _FakeInvitationRepository();
    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(repository.listCallCount, 1);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(repository.listCallCount, greaterThanOrEqualTo(2));
  });
}
