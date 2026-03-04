import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vms_bernas/domain/entities/dashboard_io_metric_entity.dart';
import 'package:vms_bernas/domain/entities/dashboard_summary_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_info_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_result_entity.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/entities/ref_personel_entity.dart';
import 'package:vms_bernas/domain/entities/ref_visitor_type_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:vms_bernas/presentation/app/router.dart';
import 'package:vms_bernas/presentation/pages/report_dashboard_list_page.dart';
import 'package:vms_bernas/presentation/pages/report_dashboard_page.dart';
import 'package:vms_bernas/presentation/state/entity_option.dart';
import 'package:vms_bernas/presentation/state/reference_providers.dart';
import 'package:vms_bernas/presentation/state/report_dashboard_providers.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  _FakeReferenceRepository({this.shouldThrow = false});

  bool shouldThrow;
  int callCount = 0;
  String? lastEntity;

  @override
  Future<DashboardSummaryEntity> getDashboardSummary({
    required String entity,
  }) async {
    callCount += 1;
    lastEntity = entity;
    if (shouldThrow) {
      throw Exception('dashboard failed');
    }

    final normalized = entity.trim().toUpperCase();
    if (normalized == 'BERNAS') {
      return const DashboardSummaryEntity(
        visitor: DashboardIoMetricEntity(
          entity: 'BERNAS',
          totalInRecords: 10,
          totalOutRecords: 9,
          stillInCount: 1,
        ),
        contractor: DashboardIoMetricEntity(
          entity: 'BERNAS',
          totalInRecords: 2,
          totalOutRecords: 1,
          stillInCount: 1,
        ),
        whitelist: DashboardIoMetricEntity(
          entity: 'BERNAS',
          totalInRecords: 3,
          totalOutRecords: 3,
          stillInCount: 0,
        ),
      );
    }

    return const DashboardSummaryEntity(
      visitor: DashboardIoMetricEntity(
        entity: 'AGYTEK',
        totalInRecords: 839,
        totalOutRecords: 661,
        stillInCount: 178,
      ),
      contractor: DashboardIoMetricEntity(
        entity: 'AGYTEK',
        totalInRecords: 36,
        totalOutRecords: 30,
        stillInCount: 6,
      ),
      whitelist: DashboardIoMetricEntity(
        entity: 'AGYTEK',
        totalInRecords: 38,
        totalOutRecords: 38,
        stillInCount: 0,
      ),
    );
  }

  @override
  Future<List<RefEntityEntity>> getEntities() {
    throw UnimplementedError();
  }

  @override
  Future<List<RefDepartmentEntity>> getDepartments({required String entity}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RefLocationEntity>> getLocations({required String entity}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<RefVisitorTypeEntity>> getVisitorTypes() {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckIn({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }
}

Widget _buildApp({
  required _FakeReferenceRepository repository,
  void Function(ReportDashboardListFilter filter)? onListOpened,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const ReportDashboardPage()),
      GoRoute(
        path: reportDashboardListRoutePath,
        builder: (context, state) {
          final extra = state.extra as ReportDashboardListFilter;
          onListOpened?.call(extra);
          return const Scaffold(body: Text('List Opened'));
        },
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      getDashboardSummaryUseCaseProvider.overrideWithValue(
        GetDashboardSummaryUseCase(repository),
      ),
      entityOptionsProvider.overrideWith(
        (ref) async => const [
          EntityOption(value: 'AGYTEK', label: 'AGYTEK'),
          EntityOption(value: 'BERNAS', label: 'BERNAS'),
        ],
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('initial entity auto-selection triggers fetch', (tester) async {
    final repository = _FakeReferenceRepository();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.callCount, 1);
    expect(repository.lastEntity, 'AGYTEK');
  });

  testWidgets('kpi values render from API state', (tester) async {
    final repository = _FakeReferenceRepository();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('839'), findsOneWidget);
    expect(find.text('661'), findsOneWidget);
    expect(find.text('178'), findsOneWidget);
  });

  testWidgets('app bar filter opens and apply refetches selected entity', (
    tester,
  ) async {
    final repository = _FakeReferenceRepository();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AGYTEK').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('BERNAS').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastEntity, 'BERNAS');
    expect(repository.callCount, 2);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('retry button refetches after error', (tester) async {
    final repository = _FakeReferenceRepository(shouldThrow: true);

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('dashboard failed'), findsOneWidget);
    expect(repository.callCount, 1);

    repository.shouldThrow = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.callCount, 2);
    expect(find.text('839'), findsOneWidget);
  });

  testWidgets('kpi tap navigates with selected entity', (tester) async {
    final repository = _FakeReferenceRepository();
    ReportDashboardListFilter? captured;

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        onListOpened: (filter) => captured = filter,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Total IN').first);
    await tester.pumpAndSettle();

    expect(find.text('List Opened'), findsOneWidget);
    expect(captured, isNotNull);
    expect(captured?.status, 'IN');
    expect(captured?.entity, 'AGYTEK');
  });
}
