import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
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
import 'package:vms_bernas/domain/usecases/get_whitelist_detail_usecase.dart';
import 'package:vms_bernas/domain/usecases/delete_whitelist_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/save_whitelist_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_whitelist_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_whitelist_check_out_usecase.dart';
import 'package:vms_bernas/presentation/pages/whitelist_detail_page.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:vms_bernas/presentation/state/whitelist_check_providers.dart';
import 'package:vms_bernas/presentation/state/whitelist_detail_providers.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  _FakeWhitelistRepository({this.submitShouldThrow = false});

  final bool submitShouldThrow;
  int callCount = 0;
  WhitelistSubmitEntity? capturedSubmission;
  String? capturedIdempotencyKey;
  WhitelistSavePhotoSubmissionEntity? capturedSavePhotoSubmission;
  int? capturedDeletedPhotoId;

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) async {
    callCount += 1;
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
  Future<List<WhitelistGalleryItemEntity>> getWhitelistGalleryList({
    required String guid,
  }) async {
    return const <WhitelistGalleryItemEntity>[];
  }

  @override
  Future<Uint8List?> getWhitelistPhoto({required int photoId}) async => null;

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

  @override
  Future<WhitelistSavePhotoResultEntity> saveWhitelistPhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) async {
    capturedSavePhotoSubmission = submission;
    return const WhitelistSavePhotoResultEntity(
      success: true,
      message: 'Photo saved successfully',
      photoId: 31,
    );
  }

  @override
  Future<WhitelistDeletePhotoResultEntity> deleteWhitelistPhoto({
    required int photoId,
  }) async {
    capturedDeletedPhotoId = photoId;
    return const WhitelistDeletePhotoResultEntity(
      success: true,
      message: 'delete is successful',
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
  Future<XFile?> Function(BuildContext context)? cameraLauncher,
  ValueChanged<WhitelistDetailPageResult?>? onResult,
}) {
  return ProviderScope(
    overrides: [
      getWhitelistDetailUseCaseProvider.overrideWithValue(
        GetWhitelistDetailUseCase(repository),
      ),
      whitelistRepositoryProvider.overrideWithValue(repository),
      submitWhitelistCheckInUseCaseProvider.overrideWithValue(
        SubmitWhitelistCheckInUseCase(repository),
      ),
      submitWhitelistCheckOutUseCaseProvider.overrideWithValue(
        SubmitWhitelistCheckOutUseCase(repository),
      ),
      saveWhitelistPhotoUseCaseProvider.overrideWithValue(
        SaveWhitelistPhotoUseCase(repository),
      ),
      deleteWhitelistPhotoUseCaseProvider.overrideWithValue(
        DeleteWhitelistPhotoUseCase(repository),
      ),
      authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
    ],
    child: MaterialApp(
      home: onResult == null
          ? WhitelistDetailPage(
              args: WhitelistDetailRouteArgs(
                entity: 'AGYTEK',
                vehiclePlate: 'www9233G',
                checkType: checkType,
              ),
              cameraLauncher: cameraLauncher,
            )
          : _WhitelistDetailTestHost(
              checkType: checkType,
              cameraLauncher: cameraLauncher,
              onResult: onResult,
            ),
    ),
  );
}

class _WhitelistDetailTestHost extends StatefulWidget {
  const _WhitelistDetailTestHost({
    required this.checkType,
    required this.onResult,
    this.cameraLauncher,
  });

  final String checkType;
  final Future<XFile?> Function(BuildContext context)? cameraLauncher;
  final ValueChanged<WhitelistDetailPageResult?> onResult;

  @override
  State<_WhitelistDetailTestHost> createState() =>
      _WhitelistDetailTestHostState();
}

class _WhitelistDetailTestHostState extends State<_WhitelistDetailTestHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await Navigator.of(context)
          .push<WhitelistDetailPageResult>(
            MaterialPageRoute(
              builder: (context) => WhitelistDetailPage(
                args: WhitelistDetailRouteArgs(
                  entity: 'AGYTEK',
                  vehiclePlate: 'www9233G',
                  checkType: widget.checkType,
                ),
                cameraLauncher: widget.cameraLauncher,
              ),
            ),
          );
      widget.onResult(result);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Host'));
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

  testWidgets('confirm submits check-in and pops with refresh result', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();
    WhitelistDetailPageResult? result;

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        checkType: 'I',
        onResult: (value) => result = value,
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result?.shouldRefresh, isTrue);
    expect(result?.message, 'Whitelist checked IN successfully.');
    expect(find.byType(WhitelistDetailPage), findsNothing);
  });

  testWidgets('confirm submits check-out and pops with refresh result', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();
    WhitelistDetailPageResult? result;

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        checkType: 'O',
        onResult: (value) => result = value,
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-Out'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result?.shouldRefresh, isTrue);
    expect(result?.message, 'Whitelist checked OUT successfully.');
    expect(find.byType(WhitelistDetailPage), findsNothing);
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

  testWidgets('camera upload shows sheet and appends gallery item', (
    tester,
  ) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        checkType: 'I',
        cameraLauncher: (_) async => XFile.fromData(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
          ),
          name: 'camera.png',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Photo'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'Gate shot');
    await tester.tap(find.widgetWithText(FilledButton, 'Upload'));
    await tester.pumpAndSettle();

    expect(repository.capturedSavePhotoSubmission?.guid, isNotEmpty);
    expect(
      repository.capturedSavePhotoSubmission?.photoDescription,
      'Gate shot',
    );
    expect(find.text('Photo saved successfully'), findsOneWidget);
    expect(
      find.byKey(const Key('whitelist-gallery-delete-31')),
      findsOneWidget,
    );
  });

  testWidgets('delete photo removes gallery item locally', (tester) async {
    final repository = _FakeWhitelistRepository();

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        checkType: 'I',
        cameraLauncher: (_) async => XFile.fromData(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
          ),
          name: 'camera.png',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Upload'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('whitelist-gallery-delete-31')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('whitelist-gallery-delete-31')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.capturedDeletedPhotoId, 31);
    expect(find.byKey(const Key('whitelist-gallery-delete-31')), findsNothing);
    expect(find.text('delete is successful'), findsOneWidget);
  });
}
