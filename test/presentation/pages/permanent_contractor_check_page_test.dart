import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/domain/entities/dashboard_summary_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_info_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_entity.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_result_entity.dart';
import 'package:vms_bernas/domain/entities/ref_department_entity.dart';
import 'package:vms_bernas/domain/entities/ref_entity_entity.dart';
import 'package:vms_bernas/domain/entities/ref_location_entity.dart';
import 'package:vms_bernas/domain/entities/ref_personel_entity.dart';
import 'package:vms_bernas/domain/entities/ref_visitor_type_entity.dart';
import 'package:vms_bernas/domain/repositories/reference_repository.dart';
import 'package:vms_bernas/domain/usecases/delete_permanent_contractor_gallery_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_permanent_contractor_info_usecase.dart';
import 'package:vms_bernas/domain/usecases/save_permanent_contractor_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_permanent_contractor_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_permanent_contractor_check_out_usecase.dart';
import 'package:vms_bernas/presentation/pages/permanent_contractor_check_page.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:vms_bernas/presentation/state/permanent_contractor_check_providers.dart';
import 'package:vms_bernas/presentation/state/reference_providers.dart';

class _FakeReferenceRepository implements ReferenceRepository {
  _FakeReferenceRepository({
    this.error,
    this.imageBytes,
    this.initialGalleryItems = const <PermanentContractorGalleryItemEntity>[],
  });

  final Object? error;
  final Uint8List? imageBytes;
  final List<PermanentContractorGalleryItemEntity> initialGalleryItems;
  PermanentContractorSubmitEntity? lastCheckInSubmission;
  PermanentContractorSubmitEntity? lastCheckOutSubmission;
  PermanentContractorSavePhotoSubmissionEntity? lastSavePhotoSubmission;
  int? lastDeletedPhotoId;
  int _nextSavedPhotoId = 53;

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) async {
    if (error != null) {
      throw error!;
    }
    return const PermanentContractorInfoEntity(
      contractorId: 'C0023',
      contractorName: 'Dylan Myer',
      contractorIc: '',
      hpNo: '0111111111',
      email: 'angypin8978@gmail.com',
      company: 'MMG (M) SDN BHD',
      validWorkingDateFrom: '2026-01-01T00:00:00',
      validWorkingDateTo: '2026-12-31T00:00:00',
    );
  }

  @override
  Future<List<RefEntityEntity>> getEntities() async => const [];

  @override
  Future<List<RefDepartmentEntity>> getDepartments({
    required String entity,
  }) async => const [];

  @override
  Future<List<RefLocationEntity>> getLocations({
    required String entity,
  }) async => const [];

  @override
  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  }) async => const [];

  @override
  Future<List<RefVisitorTypeEntity>> getVisitorTypes() async => const [];

  @override
  Future<DashboardSummaryEntity> getDashboardSummary({required String entity}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) async => imageBytes;

  @override
  Future<List<PermanentContractorGalleryItemEntity>>
  getPermanentContractorGalleryList({required String guid}) async {
    return initialGalleryItems;
  }

  @override
  Future<Uint8List?> getPermanentContractorGalleryPhoto({
    required int photoId,
  }) async => imageBytes;

  @override
  Future<PermanentContractorSavePhotoResultEntity>
  savePermanentContractorPhoto({
    required PermanentContractorSavePhotoSubmissionEntity submission,
  }) async {
    lastSavePhotoSubmission = submission;
    return PermanentContractorSavePhotoResultEntity(
      success: true,
      message: 'Photo saved successfully',
      photoId: _nextSavedPhotoId++,
    );
  }

  @override
  Future<PermanentContractorDeletePhotoResultEntity>
  deletePermanentContractorGalleryPhoto({required int photoId}) async {
    lastDeletedPhotoId = photoId;
    return const PermanentContractorDeletePhotoResultEntity(
      success: true,
      message: 'delete is successful',
    );
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckIn({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    lastCheckInSubmission = submission;
    return const PermanentContractorSubmitResultEntity(
      status: true,
      message: 'Checked-in successfully.',
    );
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    lastCheckOutSubmission = submission;
    return const PermanentContractorSubmitResultEntity(
      status: true,
      message: 'Checked-out successfully.',
    );
  }
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

Widget _buildApp({
  required ReferenceRepository repository,
  AuthLocalDataSource? authLocalDataSource,
  PermanentContractorCheckType initialCheckType =
      PermanentContractorCheckType.checkOut,
  Future<String?> Function(BuildContext context)? scanLauncher,
  Future<XFile?> Function(BuildContext context)? cameraLauncher,
}) {
  return ProviderScope(
    overrides: [
      referenceRepositoryProvider.overrideWithValue(repository),
      getPermanentContractorInfoUseCaseProvider.overrideWithValue(
        GetPermanentContractorInfoUseCase(repository),
      ),
      submitPermanentContractorCheckInUseCaseProvider.overrideWithValue(
        SubmitPermanentContractorCheckInUseCase(repository),
      ),
      submitPermanentContractorCheckOutUseCaseProvider.overrideWithValue(
        SubmitPermanentContractorCheckOutUseCase(repository),
      ),
      savePermanentContractorPhotoUseCaseProvider.overrideWithValue(
        SavePermanentContractorPhotoUseCase(repository),
      ),
      deletePermanentContractorGalleryPhotoUseCaseProvider.overrideWithValue(
        DeletePermanentContractorGalleryPhotoUseCase(repository),
      ),
      if (authLocalDataSource != null)
        authLocalDataSourceProvider.overrideWithValue(authLocalDataSource),
    ],
    child: MaterialApp(
      home: PermanentContractorCheckPage(
        initialCheckType: initialCheckType,
        scanLauncher: scanLauncher,
        cameraLauncher: cameraLauncher,
      ),
    ),
  );
}

void main() {
  final session = _FakeAuthLocalDataSource(
    const AuthSessionDto(
      username: 'Ryan',
      fullname: 'Ryan',
      entity: 'AGYTEK',
      accessToken: 'token',
      defaultSite: 'FACTORY1',
      defaultGate: 'F1_A',
    ),
  );

  testWidgets('renders with preselected check type from route context', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(repository: _FakeReferenceRepository()));
    await tester.pump();

    expect(find.text('Check-Out'), findsOneWidget);
  });

  testWidgets('search success shows info and clears input', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        repository: _FakeReferenceRepository(),
        authLocalDataSource: session,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('C0023'), findsOneWidget);
    expect(find.text('Dylan Myer'), findsOneWidget);
    expect(find.text('CON|C0023||'), findsNothing);
  });

  testWidgets('search failure shows error and keeps input', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        repository: _FakeReferenceRepository(error: Exception('failed')),
        authLocalDataSource: session,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|BAD||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('failed'), findsOneWidget);
    expect(find.text('CON|BAD||'), findsOneWidget);
  });

  testWidgets('shows contractor image and opens fullscreen on tap', (
    tester,
  ) async {
    final repository = _FakeReferenceRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5mWz8AAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(
      _buildApp(repository: repository, authLocalDataSource: session),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.byKey(const Key('permanent-contractor-photo-thumbnail')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const Key('permanent-contractor-photo-fullscreen')),
      findsOneWidget,
    );
  });

  testWidgets('confirm check-out submits payload and resets session', (
    tester,
  ) async {
    final repository = _FakeReferenceRepository();
    await tester.pumpWidget(
      _buildApp(repository: repository, authLocalDataSource: session),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-Out'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastCheckOutSubmission, isNotNull);
    expect(repository.lastCheckOutSubmission?.contractorId, 'C0023');
    expect(repository.lastCheckOutSubmission?.site, 'FACTORY1');
    expect(repository.lastCheckOutSubmission?.gate, 'F1_A');
    expect(repository.lastCheckOutSubmission?.createdBy, 'Ryan');
    expect(find.text('C0023'), findsNothing);
    expect(
      find.byKey(const Key('permanent-contractor-gallery-camera-button')),
      findsNothing,
    );
  });

  testWidgets('confirm check-in submits payload', (tester) async {
    final repository = _FakeReferenceRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        initialCheckType: PermanentContractorCheckType.checkIn,
        authLocalDataSource: session,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(repository.lastCheckInSubmission, isNotNull);
    expect(repository.lastCheckInSubmission?.contractorId, 'C0023');
  });

  testWidgets('scan qr button triggers search with scanned value', (
    tester,
  ) async {
    final repository = _FakeReferenceRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        scanLauncher: (_) async => 'CON|C0023||',
        authLocalDataSource: session,
      ),
    );

    await tester.tap(find.byIcon(Icons.qr_code_scanner));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('C0023'), findsOneWidget);
    expect(find.text('Dylan Myer'), findsOneWidget);
  });

  testWidgets('camera upload appends gallery item and uses session guid', (
    tester,
  ) async {
    final repository = _FakeReferenceRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5mWz8AAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        initialCheckType: PermanentContractorCheckType.checkIn,
        authLocalDataSource: session,
        cameraLauncher: (_) async => XFile.fromData(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
          ),
          name: 'contractor-camera.png',
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final listView = find.byType(ListView).first;
    await tester.drag(listView, const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('permanent-contractor-gallery-camera-button')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Gate shot');
    await tester.tap(find.widgetWithText(FilledButton, 'Upload'));
    await tester.pumpAndSettle();

    expect(repository.lastSavePhotoSubmission?.guid, isNotEmpty);
    expect(repository.lastSavePhotoSubmission?.photoDescription, 'Gate shot');
    expect(find.text('Photo saved successfully'), findsOneWidget);
    expect(find.text('No photos uploaded for this session.'), findsNothing);
  });

  testWidgets('delete photo removes gallery item locally', (tester) async {
    final repository = _FakeReferenceRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5mWz8AAAAASUVORK5CYII=',
      ),
      initialGalleryItems: const [
        PermanentContractorGalleryItemEntity(
          photoId: 53,
          photoDesc: 'string',
          url: '/Contractor/photo/53',
        ),
      ],
    );
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        initialCheckType: PermanentContractorCheckType.checkIn,
        authLocalDataSource: session,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final listView = find.byType(ListView).first;
    await tester.drag(listView, const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('permanent-contractor-gallery-delete-53')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.lastDeletedPhotoId, 53);
    expect(
      find.byKey(const Key('permanent-contractor-gallery-delete-53')),
      findsNothing,
    );
    expect(find.text('delete is successful'), findsOneWidget);
  });

  testWidgets(
    'successful submit resets contractor session and next upload uses new guid',
    (tester) async {
      final repository = _FakeReferenceRepository(
        imageBytes: base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5mWz8AAAAASUVORK5CYII=',
        ),
      );
      await tester.pumpWidget(
        _buildApp(
          repository: repository,
          initialCheckType: PermanentContractorCheckType.checkIn,
          authLocalDataSource: session,
          cameraLauncher: (_) async => XFile.fromData(
            base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
            ),
            name: 'contractor-camera.png',
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final listView = find.byType(ListView).first;
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('permanent-contractor-gallery-camera-button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Upload'));
      await tester.pumpAndSettle();

      final firstGuid = repository.lastSavePhotoSubmission?.guid;
      expect(firstGuid, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
      await tester.pumpAndSettle();

      expect(find.text('Checked-in successfully.'), findsOneWidget);
      expect(find.text('C0023'), findsNothing);
      expect(
        find.byKey(const Key('permanent-contractor-gallery-camera-button')),
        findsNothing,
      );

      await tester.enterText(find.byType(TextFormField).first, 'CON|C0023||');
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('permanent-contractor-gallery-camera-button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Upload'));
      await tester.pumpAndSettle();

      final secondGuid = repository.lastSavePhotoSubmission?.guid;
      expect(secondGuid, isNotNull);
      expect(secondGuid, isNot(firstGuid));
    },
  );
}
