import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/get_visitor_lookup_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_visitor_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_visitor_check_out_usecase.dart';
import 'package:vms_bernas/presentation/pages/visitor_check_in_page.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:vms_bernas/presentation/state/visitor_check_in_providers.dart';
import 'package:vms_bernas/presentation/widgets/labeled_form_rows.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  _FakeVisitorAccessRepository({
    this.error,
    this.lookup,
    this.lookupResponses,
    this.imageBytes,
    this.imageDelay,
    this.imageError,
  });

  final Object? error;
  final VisitorLookupEntity? lookup;
  final List<VisitorLookupEntity>? lookupResponses;
  final Uint8List? imageBytes;
  final Duration? imageDelay;
  final Object? imageError;
  VisitorSavePhotoResultEntity savePhotoResult =
      const VisitorSavePhotoResultEntity(
        success: true,
        message: 'Photo saved successfully',
        photoId: 45,
      );
  Object? savePhotoError;
  final List<VisitorGalleryItemEntity> galleryItems =
      <VisitorGalleryItemEntity>[
        VisitorGalleryItemEntity(
          photoId: 29,
          photoDesc: 'Sample',
          url: '/visitor/photo/29',
        ),
      ];
  bool? lastIsCheckIn;
  VisitorCheckInSubmissionEntity? lastCheckInSubmission;
  VisitorCheckInSubmissionEntity? lastCheckOutSubmission;
  VisitorSavePhotoSubmissionEntity? lastSavePhotoSubmission;
  int? lastDeletedPhotoId;
  Object? deletePhotoError;
  int lookupCalls = 0;
  int galleryListCalls = 0;

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    lastIsCheckIn = isCheckIn;
    lookupCalls += 1;
    if (error != null) {
      throw error!;
    }
    if (lookupResponses != null && lookupResponses!.isNotEmpty) {
      final index = (lookupCalls - 1).clamp(0, lookupResponses!.length - 1);
      return lookupResponses![index];
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

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    lastCheckInSubmission = submission;
    return const VisitorCheckInResultEntity(
      status: true,
      message: 'Checked-in successfully.',
    );
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    lastCheckOutSubmission = submission;
    return const VisitorCheckInResultEntity(
      status: true,
      message: 'Checked-out successfully.',
    );
  }

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) async {
    if (imageDelay != null) {
      await Future<void>.delayed(imageDelay!);
    }
    if (imageError != null) {
      throw imageError!;
    }
    return imageBytes;
  }

  @override
  Future<List<VisitorGalleryItemEntity>> getVisitorGalleryList({
    required String invitationId,
  }) async {
    galleryListCalls += 1;
    return galleryItems;
  }

  @override
  Future<Uint8List?> getVisitorGalleryPhoto({required int photoId}) async {
    return imageBytes;
  }

  @override
  Future<VisitorSavePhotoResultEntity> saveVisitorPhoto({
    required VisitorSavePhotoSubmissionEntity submission,
  }) async {
    lastSavePhotoSubmission = submission;
    if (savePhotoError != null) {
      throw savePhotoError!;
    }
    return savePhotoResult;
  }

  @override
  Future<VisitorDeletePhotoResultEntity> deleteVisitorGalleryPhoto({
    required int photoId,
  }) async {
    lastDeletedPhotoId = photoId;
    if (deletePhotoError != null) {
      throw deletePhotoError!;
    }
    galleryItems.removeWhere((item) => item.photoId == photoId);
    return const VisitorDeletePhotoResultEntity(
      success: true,
      message: 'Photo deleted successfully',
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
  required VisitorAccessRepository repository,
  required bool isCheckIn,
  AuthLocalDataSource? authLocalDataSource,
  Future<String?> Function(BuildContext context)? scanLauncher,
  Future<String?> Function(BuildContext context)? physicalTagScanLauncher,
  Future<XFile?> Function(BuildContext context)? cameraLauncher,
}) {
  return ProviderScope(
    overrides: [
      visitorAccessRepositoryProvider.overrideWithValue(repository),
      getVisitorLookupUseCaseProvider.overrideWithValue(
        GetVisitorLookupUseCase(repository),
      ),
      submitVisitorCheckInUseCaseProvider.overrideWithValue(
        SubmitVisitorCheckInUseCase(repository),
      ),
      submitVisitorCheckOutUseCaseProvider.overrideWithValue(
        SubmitVisitorCheckOutUseCase(repository),
      ),
      if (authLocalDataSource != null)
        authLocalDataSourceProvider.overrideWithValue(authLocalDataSource),
    ],
    child: MaterialApp(
      home: VisitorCheckInPage(
        isCheckIn: isCheckIn,
        scanLauncher: scanLauncher,
        physicalTagScanLauncher: physicalTagScanLauncher,
        cameraLauncher: cameraLauncher,
      ),
    ),
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

    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('Name'), findsNothing);
    expect(find.text('Visitor Photo'), findsNothing);
    expect(find.text('Check In/Out'), findsNothing);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('IN'), findsOneWidget);
    expect(find.text('KAK -V036'), findsOneWidget);
  });

  testWidgets('history button returns to summary gallery without modal', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Visitor Summary'), findsNothing);

    final historyFinder = find.byKey(const Key('visitor-history-12345656123'));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.ensureVisible(historyFinder);
    await tester.tap(historyFinder);
    await tester.pumpAndSettle();

    expect(find.text('Visitor Summary'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
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

  testWidgets('scan icon auto-searches with scanned value', (tester) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        scanLauncher: (_) async => 'VIS|SCANNED|A|F',
      ),
    );

    await tester.tap(find.byIcon(Icons.qr_code_scanner).first);
    await tester.pumpAndSettle();

    expect(repository.lastIsCheckIn, isTrue);
    expect(find.text('IV20260200038'), findsOneWidget);
  });

  testWidgets('scan icon with empty result does not trigger search', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        scanLauncher: (_) async => '   ',
      ),
    );

    await tester.tap(find.byIcon(Icons.qr_code_scanner).first);
    await tester.pumpAndSettle();

    expect(repository.lastIsCheckIn, isNull);
    expect(find.text('IV20260200038'), findsNothing);
  });

  testWidgets('camera capture opens upload modal and uploads successfully', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        authLocalDataSource: _FakeAuthLocalDataSource(
          const AuthSessionDto(
            username: 'Ryan',
            fullname: 'Ryan',
            entity: 'AGYTEK',
            accessToken: 'token',
            defaultSite: 'FACTORY1',
            defaultGate: 'F1_A',
          ),
        ),
        cameraLauncher: (_) async => XFile.fromData(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
          ),
          name: 'photo.png',
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Camera'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Photo'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Photo Description (Optional)'),
      'Gate camera',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Upload'));
    await tester.pumpAndSettle();

    expect(find.text('Photo saved successfully'), findsOneWidget);
    expect(repository.lastSavePhotoSubmission?.invitationId, 'IV20260200038');
    expect(repository.lastSavePhotoSubmission?.photoDescription, 'Gate camera');
    expect(repository.lastSavePhotoSubmission?.uploadedBy, 'Ryan');
  });

  testWidgets('camera cancel does not open upload modal', (tester) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        authLocalDataSource: _FakeAuthLocalDataSource(
          const AuthSessionDto(
            username: 'Ryan',
            fullname: 'Ryan',
            entity: 'AGYTEK',
            accessToken: 'token',
            defaultSite: 'FACTORY1',
            defaultGate: 'F1_A',
          ),
        ),
        cameraLauncher: (_) async => null,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Camera'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(find.text('Upload Photo'), findsNothing);
    expect(repository.lastSavePhotoSubmission, isNull);
  });

  testWidgets('camera upload failure keeps modal open with error', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        authLocalDataSource: _FakeAuthLocalDataSource(
          const AuthSessionDto(
            username: 'Ryan',
            fullname: 'Ryan',
            entity: 'AGYTEK',
            accessToken: 'token',
            defaultSite: 'FACTORY1',
            defaultGate: 'F1_A',
          ),
        ),
        cameraLauncher: (_) async => XFile.fromData(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
          ),
          name: 'photo.png',
        ),
      ),
    );
    repository.savePhotoError = Exception('Upload failed');

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Camera'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Upload'));
    await tester.pumpAndSettle();

    expect(find.text('Upload failed'), findsOneWidget);
    expect(find.text('Upload Photo'), findsOneWidget);
  });

  testWidgets('camera upload blocks when required session values missing', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        authLocalDataSource: _FakeAuthLocalDataSource(
          const AuthSessionDto(
            username: '',
            fullname: 'Ryan',
            entity: '',
            accessToken: 'token',
            defaultSite: '',
            defaultGate: 'F1_A',
          ),
        ),
        cameraLauncher: (_) async => XFile.fromData(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
          ),
          name: 'photo.png',
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Camera'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(find.text('Please login again to upload photo.'), findsOneWidget);
    expect(repository.lastSavePhotoSubmission, isNull);
  });

  testWidgets('gallery delete success removes item locally without refetch', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository();
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const Key('gallery-delete-29')),
      find.byType(CustomScrollView),
      const Offset(0, -280),
    );
    expect(find.byKey(const Key('gallery-delete-29')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete photo?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.lastDeletedPhotoId, 29);
    expect(repository.galleryListCalls, 1);
    expect(find.byKey(const Key('gallery-delete-29')), findsNothing);
    expect(find.text('Photo deleted successfully'), findsOneWidget);
  });

  testWidgets('gallery delete failure keeps item and shows error', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository()
      ..deletePhotoError = Exception('Delete failed');
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const Key('gallery-delete-29')),
      find.byType(CustomScrollView),
      const Offset(0, -280),
    );
    expect(find.byKey(const Key('gallery-delete-29')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gallery-delete-29')), findsOneWidget);
    expect(find.text('Delete failed'), findsOneWidget);
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

  testWidgets('check-in mode disables visitor already checked in', (
    tester,
  ) async {
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
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Already checked in'), findsNothing);
    expect(find.text('IN'), findsOneWidget);
    expect(find.text('Select all (0/0)'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm Check-In'),
          )
          .onPressed,
      isNull,
    );
    expect(find.byKey(const Key('physical-tag-input-123')), findsNothing);
    expect(find.byKey(const Key('physical-tag-scan-123')), findsNothing);
  });

  testWidgets('check-out mode disables visitor already checked out', (
    tester,
  ) async {
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

    expect(find.text('Already checked out'), findsNothing);
    expect(find.text('OUT'), findsOneWidget);
    expect(find.text('Select all (0/0)'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm Check-Out'),
          )
          .onPressed,
      isNull,
    );
    expect(find.byKey(const Key('physical-tag-input-123')), findsNothing);
    expect(find.byKey(const Key('physical-tag-scan-123')), findsNothing);
  });

  testWidgets(
    'check-in eligible row shows editable physical tag and scan icon',
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
      await tester.pumpWidget(
        _buildApp(repository: repository, isCheckIn: true),
      );

      await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visitor List (1)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('physical-tag-input-222')), findsOneWidget);
      expect(find.byKey(const Key('physical-tag-scan-222')), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const Key('physical-tag-input-222')),
            )
            .enabled,
        isFalse,
      );
      await tester.tap(find.text('Select all (0/1)'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const Key('physical-tag-input-222')),
            )
            .enabled,
        isTrue,
      );
    },
  );

  testWidgets(
    'check-in submit is blocked when selected visitor physical tag is blank',
    (tester) async {
      const lookup = VisitorLookupEntity(
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
            name: 'NAME2',
            icPassport: '123456561231',
            physicalTag: '',
            email: '',
            contactNo: '',
            company: '',
            checkInTime: '',
            checkOutTime: '',
          ),
        ],
      );
      final repository = _FakeVisitorAccessRepository(
        lookupResponses: const [lookup, lookup],
      );
      final authLocalDataSource = _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: "AGYTEK",
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          repository: repository,
          isCheckIn: true,
          authLocalDataSource: authLocalDataSource,
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visitor List (1)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select all (0/1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Summary'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Physical Tag is required for selected visitors before check-in.',
        ),
        findsOneWidget,
      );
      expect(find.text('Select all (1/1)'), findsOneWidget);
      expect(find.text('Required'), findsNWidgets(2));
      final focusedEditable = find.descendant(
        of: find.byKey(const Key('physical-tag-input-123456561231')),
        matching: find.byType(EditableText),
      );
      expect(
        tester.widget<EditableText>(focusedEditable).focusNode.hasFocus,
        isTrue,
      );
      expect(repository.lastCheckInSubmission, isNull);
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

    expect(find.text('IN'), findsOneWidget);
    expect(find.text('OUT'), findsNothing);
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

  testWidgets('unknown status hides top-right status tag', (tester) async {
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
          name: 'NO_STATUS',
          icPassport: '333',
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
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();

    expect(find.text('IN'), findsNothing);
    expect(find.text('OUT'), findsNothing);
  });

  testWidgets(
    'confirm check-in submits payload and refreshes lookup after success',
    (tester) async {
      const beforeSubmit = VisitorLookupEntity(
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
            name: 'NAME2',
            icPassport: '123456561231',
            physicalTag: '',
            email: '',
            contactNo: '',
            company: '',
            checkInTime: '',
            checkOutTime: '',
          ),
        ],
      );
      const afterSubmit = VisitorLookupEntity(
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
            name: 'NAME2',
            icPassport: '123456561231',
            physicalTag: '',
            email: '',
            contactNo: '',
            company: '',
            checkInTime: '2026-02-25T17:27:39.723',
            checkOutTime: '',
          ),
        ],
      );
      final repository = _FakeVisitorAccessRepository(
        lookupResponses: const [beforeSubmit, afterSubmit],
      );
      final authLocalDataSource = _FakeAuthLocalDataSource(
        const AuthSessionDto(
          username: 'Ryan',
          fullname: 'Ryan',
          entity: "AGYTEK",
          accessToken: 'token123',
          defaultSite: 'FACTORY1',
          defaultGate: 'F1_A',
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          repository: repository,
          isCheckIn: true,
          authLocalDataSource: authLocalDataSource,
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visitor List (1)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select all (0/1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
      await tester.pumpAndSettle();
      expect(repository.lastCheckInSubmission, isNull);
      expect(find.text('Required'), findsNWidgets(2));

      await tester.enterText(
        find.byKey(const Key('physical-tag-input-123456561231')),
        'TAG-EDITED',
      );
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
      await tester.pumpAndSettle();

      expect(repository.lastCheckInSubmission, isNotNull);
      expect(repository.lastCheckInSubmission?.userId, 'Ryan');
      expect(repository.lastCheckInSubmission?.site, 'FACTORY1');
      expect(repository.lastCheckInSubmission?.gate, 'F1_A');
      expect(repository.lastCheckInSubmission?.entity, 'AGYTEK');
      expect(repository.lastCheckInSubmission?.invitationId, 'IV20260200038');
      expect(
        repository.lastCheckInSubmission?.visitors.first.appId,
        '123456561231',
      );
      expect(
        repository.lastCheckInSubmission?.visitors.first.physicalTag,
        'TAG-EDITED',
      );
      expect(repository.lookupCalls, greaterThanOrEqualTo(2));
      expect(find.text('Checked-in successfully.'), findsOneWidget);
      await tester.tap(find.text('Visitor List (1)'));
      await tester.pumpAndSettle();
      expect(find.text('IN'), findsOneWidget);
    },
  );

  testWidgets('scan physical tag updates input and submits scanned value', (
    tester,
  ) async {
    const beforeSubmit = VisitorLookupEntity(
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
          name: 'NAME2',
          icPassport: '123456561231',
          physicalTag: '',
          email: '',
          contactNo: '',
          company: '',
          checkInTime: '',
          checkOutTime: '',
        ),
      ],
    );
    final repository = _FakeVisitorAccessRepository(
      lookupResponses: const [beforeSubmit, beforeSubmit],
    );
    final authLocalDataSource = _FakeAuthLocalDataSource(
      const AuthSessionDto(
        username: 'Ryan',
        fullname: 'Ryan',
        entity: "AGYTEK",
        accessToken: 'token123',
        defaultSite: 'FACTORY1',
        defaultGate: 'F1_A',
      ),
    );

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: true,
        authLocalDataSource: authLocalDataSource,
        physicalTagScanLauncher: (_) async => 'SCANNED-TAG',
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
    await tester.pumpAndSettle();
    expect(repository.lastCheckInSubmission, isNull);
    expect(find.text('Required'), findsNWidgets(2));

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('physical-tag-input-123456561231')),
          )
          .enabled,
      isTrue,
    );
    final scanTagFinder = find.byKey(
      const Key('physical-tag-scan-123456561231'),
    );
    final scanButtonWidget = tester.widget<CompactSuffixTapIcon>(scanTagFinder);
    expect(scanButtonWidget.onTap, isNotNull);
    scanButtonWidget.onTap!.call();
    await tester.pumpAndSettle();
    expect(find.text('SCANNED-TAG'), findsOneWidget);
    expect(find.text('Required'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-In'));
    await tester.pumpAndSettle();

    expect(
      repository.lastCheckInSubmission?.visitors.first.physicalTag,
      'SCANNED-TAG',
    );
  });

  testWidgets('check-out confirm submits payload and refreshes lookup', (
    tester,
  ) async {
    const beforeSubmit = VisitorLookupEntity(
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
    const afterSubmit = VisitorLookupEntity(
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
          checkOutTime: '2026-02-25T18:01:39.723',
        ),
      ],
    );
    final repository = _FakeVisitorAccessRepository(
      lookupResponses: const [beforeSubmit, afterSubmit],
    );
    final authLocalDataSource = _FakeAuthLocalDataSource(
      const AuthSessionDto(
        username: 'Ryan',
        fullname: 'Ryan',
        entity: "AGYTEK",
        accessToken: 'token123',
        defaultSite: 'FACTORY1',
        defaultGate: 'F1_A',
      ),
    );
    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        isCheckIn: false,
        authLocalDataSource: authLocalDataSource,
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all (0/1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm Check-Out'));
    await tester.pumpAndSettle();

    expect(repository.lastCheckOutSubmission, isNotNull);
    expect(repository.lastCheckOutSubmission?.userId, 'Ryan');
    expect(repository.lastCheckOutSubmission?.site, 'FACTORY1');
    expect(repository.lastCheckOutSubmission?.gate, 'F1_A');
    expect(repository.lastCheckOutSubmission?.entity, 'AGYTEK');
    expect(repository.lastCheckOutSubmission?.invitationId, 'IV20260200038');
    expect(
      repository.lastCheckOutSubmission?.visitors.first.appId,
      '12345656123',
    );
    expect(repository.lookupCalls, greaterThanOrEqualTo(2));
    expect(find.text('Checked-out successfully.'), findsOneWidget);
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();
    expect(find.text('OUT'), findsOneWidget);
  });

  testWidgets('visitor photo shows loading spinner while fetching', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository(
      imageDelay: const Duration(milliseconds: 400),
    );
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('visitor photo renders image when bytes available', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('visitor photo keeps placeholder on image error', (tester) async {
    final repository = _FakeVisitorAccessRepository(
      imageError: Exception('image failed'),
    );
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person), findsWidgets);
  });

  testWidgets('visitor photo opens fullscreen preview when tapped', (
    tester,
  ) async {
    final repository = _FakeVisitorAccessRepository(
      imageBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5WcMsAAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(_buildApp(repository: repository, isCheckIn: true));

    await tester.enterText(find.byType(TextFormField).first, 'VIS|IV|A|F');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor List (1)'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('visitor-photo-thumbnail')),
    );
    await tester.tap(find.byKey(const Key('visitor-photo-thumbnail')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('visitor-photo-fullscreen')), findsOneWidget);

    await tester.tap(find.byTooltip('Close photo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('visitor-photo-fullscreen')), findsNothing);
  });
}
