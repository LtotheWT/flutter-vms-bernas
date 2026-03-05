import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/domain/entities/employee_info_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/employee_access_repository.dart';
import 'package:vms_bernas/domain/usecases/get_employee_info_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_employee_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_employee_check_out_usecase.dart';
import 'package:vms_bernas/presentation/pages/employee_check_page.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:vms_bernas/presentation/state/employee_check_providers.dart';

class _FakeEmployeeAccessRepository implements EmployeeAccessRepository {
  _FakeEmployeeAccessRepository({this.error, this.imageBytes});

  final Object? error;
  final Uint8List? imageBytes;
  String? lastLookupCode;
  EmployeeSubmitEntity? lastCheckInSubmission;
  EmployeeSubmitEntity? lastCheckOutSubmission;

  @override
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code}) async {
    lastLookupCode = code;
    if (error != null) {
      throw error!;
    }
    return const EmployeeInfoEntity(
      employeeId: 'EMP0001',
      employeeName: 'Suraya',
      site: 'FACTORY1',
      department: 'ADC',
      unit: 'ABC',
      vehicleType: 'CAR',
      handphoneNo: '2',
      telNoExtension: '3',
      effectiveWorkingDate: '2025-11-01T00:00:00',
      lastWorkingDate: '2025-11-30T00:00:00',
    );
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckIn({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    lastCheckInSubmission = submission;
    return const EmployeeSubmitResultEntity(
      status: true,
      message: 'Employee EMP0001 checked in successfully.',
      eventType: 'IN',
    );
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    lastCheckOutSubmission = submission;
    return const EmployeeSubmitResultEntity(
      status: true,
      message: 'Employee EMP0001 checked out successfully.',
      eventType: 'OUT',
    );
  }

  @override
  Future<Uint8List?> getEmployeeImage({required String employeeId}) async {
    return imageBytes;
  }
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource() : super(const FlutterSecureStorage());

  @override
  Future<AuthSessionDto?> getSession() async {
    return const AuthSessionDto(
      username: 'Ryan',
      fullname: 'Ryan',
      entity: 'AGYTEK',
      accessToken: 'token',
      defaultSite: 'FACTORY1',
      defaultGate: 'F1_A',
    );
  }
}

Widget _buildApp({
  required EmployeeAccessRepository repository,
  required EmployeeCheckType initialCheckType,
  Future<String?> Function(BuildContext context)? scanLauncher,
}) {
  return ProviderScope(
    overrides: [
      employeeAccessRepositoryProvider.overrideWithValue(repository),
      getEmployeeInfoUseCaseProvider.overrideWithValue(
        GetEmployeeInfoUseCase(repository),
      ),
      submitEmployeeCheckInUseCaseProvider.overrideWithValue(
        SubmitEmployeeCheckInUseCase(repository),
      ),
      submitEmployeeCheckOutUseCaseProvider.overrideWithValue(
        SubmitEmployeeCheckOutUseCase(repository),
      ),
      authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
    ],
    child: MaterialApp(
      home: EmployeeCheckPage(
        initialCheckType: initialCheckType,
        scanLauncher: scanLauncher,
      ),
    ),
  );
}

void main() {
  testWidgets('preselects check type from route context', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        repository: _FakeEmployeeAccessRepository(),
        initialCheckType: EmployeeCheckType.checkOut,
      ),
    );
    await tester.pump();

    expect(
      find.widgetWithText(FilledButton, 'Confirm Check-Out'),
      findsOneWidget,
    );
  });

  testWidgets('scan action triggers auto-search', (tester) async {
    final repository = _FakeEmployeeAccessRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        initialCheckType: EmployeeCheckType.checkIn,
        scanLauncher: (_) async => 'EMP|EMP0001||',
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('employee-scan-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastLookupCode, 'EMP|EMP0001||');
    expect(find.text('EMP0001'), findsOneWidget);
    expect(find.text('Suraya'), findsOneWidget);
  });

  testWidgets('search success clears input and renders details', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        repository: _FakeEmployeeAccessRepository(),
        initialCheckType: EmployeeCheckType.checkIn,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'EMP|EMP0001||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find
          .byKey(const Key('employee-photo-thumbnail'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.text('EMP0001'), findsOneWidget);
    expect(find.text('Suraya'), findsOneWidget);
    expect(find.text('EMP|EMP0001||'), findsNothing);
  });

  testWidgets('shows employee image and opens fullscreen on tap', (
    tester,
  ) async {
    final repository = _FakeEmployeeAccessRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5mWz8AAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        initialCheckType: EmployeeCheckType.checkIn,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'EMP|EMP0001||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('employee-photo-thumbnail')), findsOneWidget);
    await tester.tap(find.byKey(const Key('employee-photo-thumbnail')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('employee-photo-fullscreen')), findsOneWidget);
  });

  testWidgets('confirm submits check-out payload with session site/gate', (
    tester,
  ) async {
    final repository = _FakeEmployeeAccessRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        initialCheckType: EmployeeCheckType.checkOut,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'EMP|EMP0001||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-Out'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastCheckOutSubmission, isNotNull);
    expect(repository.lastCheckOutSubmission?.employeeId, 'EMP0001');
    expect(repository.lastCheckOutSubmission?.site, 'FACTORY1');
    expect(repository.lastCheckOutSubmission?.gate, 'F1_A');
    expect(repository.lastCheckOutSubmission?.createdBy, 'Ryan');
    expect(
      find.text('Employee EMP0001 checked out successfully.'),
      findsOneWidget,
    );
  });
}
