import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/get_whitelist_detail_usecase.dart';
import 'package:vms_bernas/presentation/pages/whitelist_detail_page.dart';
import 'package:vms_bernas/presentation/state/whitelist_detail_providers.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  _FakeWhitelistRepository({this.shouldThrow = false});

  final bool shouldThrow;
  int callCount = 0;

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) async {
    callCount += 1;
    if (shouldThrow) {
      throw Exception('detail load failed');
    }
    return WhitelistDetailEntity(
      entity: entity,
      vehiclePlate: vehiclePlate,
      ic: '123456789012',
      name: 'Whitelist Name',
      status: 'ACTIVE',
      createBy: 'admin',
      createDate: '2025-12-03 10:23:10',
      updateBy: 'admin',
      updateDate: '2025-12-03 10:48:15',
    );
  }

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) {
    throw UnimplementedError();
  }
}

Widget _buildApp({
  required _FakeWhitelistRepository repository,
  required String checkType,
}) {
  return ProviderScope(
    overrides: [
      getWhitelistDetailUseCaseProvider.overrideWithValue(
        GetWhitelistDetailUseCase(repository),
      ),
    ],
    child: MaterialApp(
      home: WhitelistDetailPage(
        args: WhitelistDetailRouteArgs(
          entity: 'AGYTEK',
          vehiclePlate: 'www9233G',
          checkType: checkType,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('init triggers detail load and renders fields', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'I'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.callCount, 1);
    expect(find.text('Check-In'), findsOneWidget);
    expect(find.text('www9233G'), findsOneWidget);
    expect(find.text('123456789012'), findsOneWidget);
    expect(find.text('Whitelist Name'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Confirm'), findsOneWidget);
  });

  testWidgets('shows error state and retry works', (tester) async {
    final repository = _FakeWhitelistRepository(shouldThrow: true);

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'O'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('detail load failed'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    expect(repository.callCount, 1);

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(repository.callCount, 2);
  });

  testWidgets('confirm shows check-in placeholder message', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'I'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump();

    expect(find.text('Check-In API is not available yet.'), findsOneWidget);
  });

  testWidgets('confirm shows check-out placeholder message', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'O'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump();

    expect(find.text('Check-Out API is not available yet.'), findsOneWidget);
  });
}
