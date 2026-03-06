import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:vms_bernas/domain/usecases/delete_whitelist_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_whitelist_detail_usecase.dart';
import 'package:vms_bernas/domain/usecases/save_whitelist_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_whitelist_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_whitelist_check_out_usecase.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:vms_bernas/presentation/state/whitelist_detail_providers.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  _FakeWhitelistRepository({
    this.shouldThrow = false,
    this.submitShouldThrow = false,
    this.submitDelay = Duration.zero,
  });

  final bool shouldThrow;
  final bool submitShouldThrow;
  final Duration submitDelay;
  String? lastEntity;
  String? lastVehiclePlate;
  WhitelistSubmitEntity? lastSubmission;
  String? lastIdempotencyKey;
  WhitelistSavePhotoSubmissionEntity? lastSavePhotoSubmission;
  int? lastDeletedPhotoId;

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) async {
    lastEntity = entity;
    lastVehiclePlate = vehiclePlate;
    if (shouldThrow) {
      throw Exception('detail failed');
    }
    return const WhitelistDetailEntity(
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
      ic: '123456789012',
      name: 'John',
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
    if (submitDelay > Duration.zero) {
      await Future<void>.delayed(submitDelay);
    }
    lastSubmission = submission;
    lastIdempotencyKey = idempotencyKey;
    if (submitShouldThrow) {
      throw Exception('submit failed');
    }
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
    if (submitDelay > Duration.zero) {
      await Future<void>.delayed(submitDelay);
    }
    lastSubmission = submission;
    lastIdempotencyKey = idempotencyKey;
    if (submitShouldThrow) {
      throw Exception('submit failed');
    }
    return const WhitelistSubmitResultEntity(
      status: true,
      message: 'Whitelist checked OUT successfully.',
    );
  }

  @override
  Future<WhitelistSavePhotoResultEntity> saveWhitelistPhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) async {
    lastSavePhotoSubmission = submission;
    if (submitShouldThrow) {
      throw Exception('photo submit failed');
    }
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
    lastDeletedPhotoId = photoId;
    if (submitShouldThrow) {
      throw Exception('photo delete failed');
    }
    return const WhitelistDeletePhotoResultEntity(
      success: true,
      message: 'delete is successful',
    );
  }
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

ProviderContainer _createContainer(_FakeWhitelistRepository repository) {
  return ProviderContainer(
    overrides: [
      authLocalDataSourceProvider.overrideWithValue(
        _FakeAuthLocalDataSource(
          const AuthSessionDto(
            username: 'Ryan',
            fullname: 'Ryan',
            entity: 'AGYTEK',
            accessToken: 'token',
            defaultSite: 'FACTORY1',
            defaultGate: 'F1_A',
          ),
        ),
      ),
      getWhitelistDetailUseCaseProvider.overrideWithValue(
        GetWhitelistDetailUseCase(repository),
      ),
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
    ],
  );
}

void main() {
  test('load success updates detail state', () async {
    final repository = _FakeWhitelistRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await container
        .read(whitelistDetailControllerProvider.notifier)
        .load(entity: 'AGYTEK', vehiclePlate: 'www9233G', checkType: 'I');

    final state = container.read(whitelistDetailControllerProvider);
    expect(repository.lastEntity, 'AGYTEK');
    expect(repository.lastVehiclePlate, 'www9233G');
    expect(state.detail, isNotNull);
    expect(state.detail?.name, 'John');
    expect(state.errorMessage, isNull);
    expect(state.hasLoaded, isTrue);
    expect(state.checkType, 'I');
  });

  test('load failure sets error state', () async {
    final repository = _FakeWhitelistRepository(shouldThrow: true);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await container
        .read(whitelistDetailControllerProvider.notifier)
        .load(entity: 'AGYTEK', vehiclePlate: 'www9233G', checkType: 'O');

    final state = container.read(whitelistDetailControllerProvider);
    expect(state.detail, isNull);
    expect(state.errorMessage, 'detail failed');
    expect(state.hasLoaded, isTrue);
    expect(state.checkType, 'O');
  });

  test('submit success reuses idempotency key for same payload', () async {
    final repository = _FakeWhitelistRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(
      whitelistDetailControllerProvider.notifier,
    );
    await controller.load(
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
      checkType: 'I',
    );

    final first = await controller.submit();
    final firstKey = repository.lastIdempotencyKey;
    final second = await controller.submit();
    final secondKey = repository.lastIdempotencyKey;

    expect(first.status, isTrue);
    expect(second.status, isTrue);
    expect(firstKey, isNotNull);
    expect(secondKey, firstKey);
  });

  test('submit failure returns normalized error and keeps state', () async {
    final repository = _FakeWhitelistRepository(submitShouldThrow: true);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(
      whitelistDetailControllerProvider.notifier,
    );
    await controller.load(
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
      checkType: 'O',
    );
    final result = await controller.submit();

    expect(result.status, isFalse);
    expect(result.message, 'submit failed');
    final state = container.read(whitelistDetailControllerProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.errorMessage, 'submit failed');
  });

  test('idempotency key resets when payload signature changes', () async {
    final repository = _FakeWhitelistRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(
      whitelistDetailControllerProvider.notifier,
    );
    await controller.load(
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
      checkType: 'I',
    );
    await controller.submit();
    final firstKey = repository.lastIdempotencyKey;

    await controller.load(
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
      checkType: 'O',
    );
    await controller.submit();
    final secondKey = repository.lastIdempotencyKey;

    expect(firstKey, isNotNull);
    expect(secondKey, isNotNull);
    expect(secondKey, isNot(firstKey));
  });

  test('duplicate submit guard returns in-progress message', () async {
    final repository = _FakeWhitelistRepository(
      submitDelay: const Duration(milliseconds: 150),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    final sub = container.listen(
      whitelistDetailControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final controller = container.read(
      whitelistDetailControllerProvider.notifier,
    );
    await controller.load(
      entity: 'AGYTEK',
      vehiclePlate: 'www9233G',
      checkType: 'I',
    );

    final firstFuture = controller.submit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final second = await controller.submit();
    final first = await firstFuture;

    expect(first.status, isTrue);
    expect(second.status, isFalse);
    expect(second.message, 'Submission is currently in progress.');
  });

  test(
    'load generates one photo session guid and reuses it on reload',
    () async {
      final repository = _FakeWhitelistRepository();
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      final controller = container.read(
        whitelistDetailControllerProvider.notifier,
      );
      await controller.load(
        entity: 'AGYTEK',
        vehiclePlate: 'www9233G',
        checkType: 'I',
      );
      final firstGuid = container
          .read(whitelistDetailControllerProvider)
          .photoSessionGuid;

      await controller.load(
        entity: 'AGYTEK',
        vehiclePlate: 'www9233G',
        checkType: 'I',
      );
      final secondGuid = container
          .read(whitelistDetailControllerProvider)
          .photoSessionGuid;

      expect(firstGuid, isNotNull);
      expect(secondGuid, firstGuid);
    },
  );

  test(
    'save photo success updates uploading state and forwards submission',
    () async {
      final repository = _FakeWhitelistRepository();
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      final result = await container
          .read(whitelistDetailControllerProvider.notifier)
          .savePhoto(
            submission: const WhitelistSavePhotoSubmissionEntity(
              imageBase64: 'abc',
              photoDescription: 'Gate',
              guid: 'guid-123',
              entity: 'AGYTEK',
              site: 'FACTORY1',
              uploadedBy: 'Ryan',
            ),
          );

      expect(result.success, isTrue);
      expect(repository.lastSavePhotoSubmission?.guid, 'guid-123');
      expect(
        container.read(whitelistDetailControllerProvider).isUploadingPhoto,
        isFalse,
      );
    },
  );

  test(
    'delete photo success clears deleting state and forwards photo id',
    () async {
      final repository = _FakeWhitelistRepository();
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      final result = await container
          .read(whitelistDetailControllerProvider.notifier)
          .deletePhoto(photoId: 31);

      expect(result.success, isTrue);
      expect(repository.lastDeletedPhotoId, 31);
      final state = container.read(whitelistDetailControllerProvider);
      expect(state.isDeletingPhoto, isFalse);
      expect(state.deletingPhotoId, isNull);
    },
  );
}
