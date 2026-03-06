import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vms_bernas/domain/entities/whitelist_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/search_whitelist_usecase.dart';
import 'package:vms_bernas/presentation/app/router.dart';
import 'package:vms_bernas/presentation/pages/whitelist_check_page.dart';
import 'package:vms_bernas/presentation/pages/whitelist_detail_page.dart';
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
  int searchCallCount = 0;

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) async {
    searchCallCount += 1;
    lastFilter = filter;
    if (shouldThrow) {
      throw Exception('boom');
    }
    return items;
  }

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) async {
    return WhitelistDetailEntity(
      entity: entity,
      vehiclePlate: vehiclePlate,
      ic: 'IC',
      name: 'NAME',
      status: 'ACTIVE',
      createBy: 'admin',
      createDate: '2026-01-13 11:46:40',
      updateBy: 'admin',
      updateDate: '2026-01-13 11:46:40',
    );
  }

  @override
  Future<List<WhitelistGalleryItemEntity>> getWhitelistGalleryList({
    required String guid,
  }) async {
    return const <WhitelistGalleryItemEntity>[];
  }

  @override
  Future<Uint8List?> getWhitelistPhoto({required int photoId}) async => null;

  @override
  Future<WhitelistSavePhotoResultEntity> saveWhitelistPhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WhitelistDeletePhotoResultEntity> deleteWhitelistPhoto({
    required int photoId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckIn({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckOut({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }
}

Widget _buildApp({
  required _FakeWhitelistRepository repository,
  required bool isCheckIn,
  void Function(WhitelistDetailRouteArgs args)? onDetailOpened,
  bool detailReturnsRefresh = false,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => WhitelistCheckPage(isCheckIn: isCheckIn),
      ),
      GoRoute(
        name: whitelistDetailRouteName,
        path: whitelistDetailRoutePath,
        builder: (context, state) {
          final args = state.extra as WhitelistDetailRouteArgs;
          onDetailOpened?.call(args);
          if (detailReturnsRefresh) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            });
          }
          return const Scaffold(body: Text('Detail Route Opened'));
        },
      ),
    ],
  );

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
    child: MaterialApp.router(routerConfig: router),
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

  testWidgets('row tap navigates to detail route with args', (tester) async {
    final repository = _FakeWhitelistRepository();
    WhitelistDetailRouteArgs? capturedArgs;

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        onDetailOpened: (args) => capturedArgs = args,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ExpansionTile), findsNothing);
    await tester.tap(find.text('Details').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail Route Opened'), findsOneWidget);
    expect(capturedArgs, isNotNull);
    expect(capturedArgs?.entity, 'AGYTEK');
    expect(capturedArgs?.vehiclePlate, 'RYAN1234');
    expect(capturedArgs?.checkType, 'I');
  });

  testWidgets('does not show select-all bulk action bar', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Select all'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('refreshes whitelist list when detail returns success', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        detailReturnsRefresh: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.searchCallCount, 1);
    await tester.tap(find.text('Details').first);
    await tester.pumpAndSettle();

    expect(repository.searchCallCount, 2);
  });
}
