import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/search_whitelist_usecase.dart';
import 'package:vms_bernas/presentation/pages/whitelist_check_page.dart';
import 'package:vms_bernas/presentation/state/entity_option.dart';
import 'package:vms_bernas/presentation/state/reference_providers.dart';
import 'package:vms_bernas/presentation/state/whitelist_check_providers.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  _FakeWhitelistRepository({
    this.shouldThrow = false,
    this.items = const <WhitelistSearchItemEntity>[
      WhitelistSearchItemEntity(
        entity: 'AGYTEK',
        vehiclePlate: 'RYAN1234',
        ic: 'RYAN',
        name: 'RYAN1234',
        status: 'ACTIVE',
        createBy: 'ryan',
        createDate: '2026-01-13 11:46:40',
        updateBy: '',
        updateDate: '',
      ),
    ],
  });

  final bool shouldThrow;
  final List<WhitelistSearchItemEntity> items;
  WhitelistSearchFilterEntity? lastFilter;

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) async {
    lastFilter = filter;
    if (shouldThrow) {
      throw Exception('boom');
    }
    return items;
  }
}

Widget _buildApp({
  required _FakeWhitelistRepository repository,
  required bool isCheckIn,
}) {
  return ProviderScope(
    overrides: [
      searchWhitelistUseCaseProvider.overrideWithValue(
        SearchWhitelistUseCase(repository),
      ),
      entityOptionsProvider.overrideWith(
        (ref) async => const [
          EntityOption(value: 'AGYTEK', label: 'AGYTEK'),
          EntityOption(value: '', label: ''),
        ],
      ),
    ],
    child: MaterialApp(home: WhitelistCheckPage(isCheckIn: isCheckIn)),
  );
}

void main() {
  testWidgets('check-in page sends CURRENT_TYPE=I on initial load', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastFilter?.currentType, 'I');
    expect(find.text('RYAN1234'), findsWidgets);
  });

  testWidgets('check-out page sends CURRENT_TYPE=O on initial load', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(
      _buildApp(repository: repository, isCheckIn: false),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastFilter?.currentType, 'O');
  });

  testWidgets('filter apply refetches with updated vehicle and ic', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'CAR123');
    await tester.enterText(find.byType(TextFormField).at(1), 'IC9988');

    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastFilter?.vehiclePlate, 'CAR123');
    expect(repository.lastFilter?.ic, 'IC9988');
    expect(repository.lastFilter?.currentType, 'I');
  });

  testWidgets('shows empty state', (tester) async {
    final repository = _FakeWhitelistRepository(items: const []);

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('No whitelist records to display.'), findsOneWidget);
  });

  testWidgets('shows error state and retry button', (tester) async {
    final repository = _FakeWhitelistRepository(shouldThrow: true);

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('boom'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('clear all resets filter inputs before apply', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'CAR111');
    await tester.enterText(find.byType(TextFormField).at(1), 'IC111');
    await tester.tap(find.widgetWithText(TextButton, 'Clear All'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastFilter?.vehiclePlate, '');
    expect(repository.lastFilter?.ic, '');
    expect(repository.lastFilter?.status, isNull);
    expect(repository.lastFilter?.entity, 'AGYTEK');
  });

  testWidgets('clear individual vehicle input works', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'CAR222');
    await tester.pump();
    expect(find.text('CAR222'), findsOneWidget);
    await tester.tap(find.byKey(const Key('whitelist-filter-clear-vehicle')));
    await tester.pumpAndSettle();

    expect(find.text('CAR222'), findsNothing);
  });

  testWidgets('does not show select-all bulk action bar', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Select all'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });
}
