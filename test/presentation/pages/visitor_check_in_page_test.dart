import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_item_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/get_visitor_lookup_usecase.dart';
import 'package:vms_bernas/presentation/pages/visitor_check_in_page.dart';
import 'package:vms_bernas/presentation/state/visitor_check_in_providers.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  _FakeVisitorAccessRepository({this.error, this.lookup});

  final Object? error;
  final VisitorLookupEntity? lookup;
  bool? lastIsCheckIn;

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    lastIsCheckIn = isCheckIn;
    if (error != null) {
      throw error!;
    }
    return lookup ??
        const VisitorLookupEntity(
          invitationId: 'IV20260200038',
          entity: 'AGYTEK',
          site: 'FACTORY1',
          siteDesc: 'FACTORY1 T',
          department: 'ADC',
          departmentDesc: 'ADMIN CENTER',
          purpose: 'MEETING',
          company: 'TEST',
          contactNumber: '0123456789',
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
              icPassport: '12345656123',
              physicalTag: 'KAK -V036',
              email: '',
              contactNo: '',
              company: '',
              checkInTime: '2026-02-25T17:27:39.723',
              checkOutTime: '',
            ),
          ],
        );
  }
}

Widget _buildApp({
  required VisitorAccessRepository repository,
  required bool isCheckIn,
}) {
  return ProviderScope(
    overrides: [
      getVisitorLookupUseCaseProvider.overrideWithValue(
        GetVisitorLookupUseCase(repository),
      ),
    ],
    child: MaterialApp(home: VisitorCheckInPage(isCheckIn: isCheckIn)),
  );
}

void main() {
  testWidgets('check-in page searches with I and renders summary/list', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    expect(repository.lastIsCheckIn, isTrue);
    expect(find.text('IV20260200038'), findsOneWidget);
    expect(find.text('Visitor List (1)'), findsOneWidget);

    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();
    expect(find.text('KAK -V036'), findsOneWidget);
  });

  testWidgets('check-out page searches with O', (tester) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(
      _buildApp(repository: repository, isCheckIn: false),
    );

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    expect(repository.lastIsCheckIn, isFalse);
  });

  testWidgets('error state is shown on failed search', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        repository: _FakeVisitorAccessRepository(
          error: Exception('Invalid code'),
        ),
        isCheckIn: true,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'VIS|BAD|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid code'), findsOneWidget);
    expect(find.text('VIS|BAD|A|F'), findsOneWidget);
  });

  testWidgets(
    'check-in mode disables visitor already checked in and shows helper text',
    (tester) async {
      const lookup = VisitorLookupEntity(
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
            name: 'IN_PERSON',
            icPassport: '123',
            physicalTag: '',
            email: '',
            contactNo: '',
            company: '',
            checkInTime: '2026-02-25T10:00:00',
            checkOutTime: '',
          ),
        ],
      );
      final repository = _FakeVisitorAccessRepository(lookup: lookup);
      await tester.pumpWidget(
        _buildApp(repository: repository, isCheckIn: true),
      );

      await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visitor List (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Already checked in'), findsOneWidget);
      expect(find.text('Select all (0/0)'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Confirm Check-In'),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets(
    'check-out mode disables visitor already checked out and shows helper text',
    (tester) async {
      const lookup = VisitorLookupEntity(
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
            name: 'OUT_PERSON',
            icPassport: '123',
            physicalTag: '',
            email: '',
            contactNo: '',
            company: '',
            checkInTime: '2026-02-25T10:00:00',
            checkOutTime: '2026-02-25T11:00:00',
          ),
        ],
      );
      final repository = _FakeVisitorAccessRepository(lookup: lookup);
      await tester.pumpWidget(
        _buildApp(repository: repository, isCheckIn: false),
      );

      await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visitor List (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Already checked out'), findsOneWidget);
      expect(find.text('Select all (0/0)'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Confirm Check-Out'),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets('select all targets only eligible visitors', (tester) async {
    const lookup = VisitorLookupEntity(
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
          name: 'INELIGIBLE',
          icPassport: '111',
          physicalTag: '',
          email: '',
          contactNo: '',
          company: '',
          checkInTime: '2026-02-25T10:00:00',
          checkOutTime: '',
        ),
        VisitorLookupItemEntity(
          name: 'ELIGIBLE',
          icPassport: '222',
          physicalTag: '',
          email: '',
          contactNo: '',
          company: '',
          checkInTime: '',
          checkOutTime: '',
        ),
      ],
    );
    final repository = _FakeVisitorAccessRepository(lookup: lookup);
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Select all (0/1)'), findsOneWidget);
    await tester.tap(find.text('Select all (0/1)'));
    await tester.pumpAndSettle();
    expect(find.text('Select all (1/1)'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm Check-In'),
          )
          .onPressed,
      isNotNull,
    );
  });
}
