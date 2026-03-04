import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/get_whitelist_detail_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_whitelist_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_whitelist_check_out_usecase.dart';
import 'package:vms_bernas/presentation/pages/whitelist_detail_page.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:vms_bernas/presentation/state/whitelist_detail_providers.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  _FakeWhitelistRepository({
    this.shouldThrow = false,
    this.submitShouldThrow = false,
  });

  final bool shouldThrow;
  final bool submitShouldThrow;
  int callCount = 0;
  WhitelistSubmitEntity? capturedSubmission;
  String? capturedIdempotencyKey;

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

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckIn({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    if (submitShouldThrow) {
      throw Exception('submit failed');
    }
    capturedSubmission = submission;
    capturedIdempotencyKey = idempotencyKey;
    return const WhitelistSubmitResultEntity(
      status: true,
      message: 'Whitelist checked IN successfully.',
    );
  }

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckOut({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    if (submitShouldThrow) {
      throw Exception('submit failed');
    }
    capturedSubmission = submission;
    capturedIdempotencyKey = idempotencyKey;
    return const WhitelistSubmitResultEntity(
      status: true,
      message: 'Whitelist checked OUT successfully.',
    );
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
  required _FakeWhitelistRepository repository,
  required String checkType,
}) {
  return ProviderScope(
    overrides: [
      getWhitelistDetailUseCaseProvider.overrideWithValue(
        GetWhitelistDetailUseCase(repository),
      ),
      submitWhitelistCheckInUseCaseProvider.overrideWithValue(
        SubmitWhitelistCheckInUseCase(repository),
      ),
      submitWhitelistCheckOutUseCaseProvider.overrideWithValue(
        SubmitWhitelistCheckOutUseCase(repository),
      ),
      authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
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
  testWidgets('confirm button is disabled before detail is loaded', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'I'));

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirm Check-In'),
    );
    expect(button.onPressed, isNull);
  });

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
    expect(
      find.widgetWithText(FilledButton, 'Confirm Check-In'),
      findsOneWidget,
    );
  });

  testWidgets('confirm submits check-in and shows success message', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'I'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
    await tester.pump();

    expect(find.text('Whitelist checked IN successfully.'), findsOneWidget);
  });

  testWidgets('confirm submits check-out and shows success message', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'O'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-Out'));
    await tester.pump();

    expect(find.text('Whitelist checked OUT successfully.'), findsOneWidget);
  });

  testWidgets('confirm submit failure shows error message', (tester) async {
    final repository = _FakeWhitelistRepository(submitShouldThrow: true);

    await tester.pumpWidget(_buildApp(repository: repository, checkType: 'I'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
    await tester.pump();

    expect(find.text('submit failed'), findsWidgets);
  });
}
