import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/whitelist_delete_photo_result_entity.dart';
import '../../domain/entities/whitelist_detail_entity.dart';
import '../../domain/entities/whitelist_gallery_item_entity.dart';
import '../../domain/entities/whitelist_save_photo_result_entity.dart';
import '../../domain/entities/whitelist_save_photo_submission_entity.dart';
import '../../domain/entities/whitelist_submit_entity.dart';
import '../../domain/entities/whitelist_submit_result_entity.dart';
import '../../domain/usecases/delete_whitelist_photo_usecase.dart';
import '../../domain/usecases/get_whitelist_detail_usecase.dart';
import '../../domain/usecases/save_whitelist_photo_usecase.dart';
import '../../domain/usecases/submit_whitelist_check_in_usecase.dart';
import '../../domain/usecases/submit_whitelist_check_out_usecase.dart';
import 'auth_session_providers.dart';
import 'photo_cache_helpers.dart';
import 'whitelist_check_providers.dart';

final getWhitelistDetailUseCaseProvider = Provider<GetWhitelistDetailUseCase>((
  ref,
) {
  final repository = ref.read(whitelistRepositoryProvider);
  return GetWhitelistDetailUseCase(repository);
});

final submitWhitelistCheckInUseCaseProvider =
    Provider<SubmitWhitelistCheckInUseCase>((ref) {
      final repository = ref.read(whitelistRepositoryProvider);
      return SubmitWhitelistCheckInUseCase(repository);
    });

final submitWhitelistCheckOutUseCaseProvider =
    Provider<SubmitWhitelistCheckOutUseCase>((ref) {
      final repository = ref.read(whitelistRepositoryProvider);
      return SubmitWhitelistCheckOutUseCase(repository);
    });

final saveWhitelistPhotoUseCaseProvider = Provider<SaveWhitelistPhotoUseCase>((
  ref,
) {
  final repository = ref.read(whitelistRepositoryProvider);
  return SaveWhitelistPhotoUseCase(repository);
});

final deleteWhitelistPhotoUseCaseProvider =
    Provider<DeleteWhitelistPhotoUseCase>((ref) {
      final repository = ref.read(whitelistRepositoryProvider);
      return DeleteWhitelistPhotoUseCase(repository);
    });

@immutable
class WhitelistDetailState {
  const WhitelistDetailState({
    this.detail,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUploadingPhoto = false,
    this.isDeletingPhoto = false,
    this.deletingPhotoId,
    this.photoSessionGuid,
    this.idempotencyKey,
    this.idempotencySignature,
    this.errorMessage,
    this.hasLoaded = false,
    this.checkType = 'I',
  });

  final WhitelistDetailEntity? detail;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUploadingPhoto;
  final bool isDeletingPhoto;
  final int? deletingPhotoId;
  final String? photoSessionGuid;
  final String? idempotencyKey;
  final String? idempotencySignature;
  final String? errorMessage;
  final bool hasLoaded;
  final String checkType;

  WhitelistDetailState copyWith({
    Object? detail = _unset,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUploadingPhoto,
    bool? isDeletingPhoto,
    Object? deletingPhotoId = _unset,
    Object? photoSessionGuid = _unset,
    Object? idempotencyKey = _unset,
    Object? idempotencySignature = _unset,
    Object? errorMessage = _unset,
    bool? hasLoaded,
    String? checkType,
  }) {
    return WhitelistDetailState(
      detail: identical(detail, _unset)
          ? this.detail
          : detail as WhitelistDetailEntity?,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isDeletingPhoto: isDeletingPhoto ?? this.isDeletingPhoto,
      deletingPhotoId: identical(deletingPhotoId, _unset)
          ? this.deletingPhotoId
          : deletingPhotoId as int?,
      photoSessionGuid: identical(photoSessionGuid, _unset)
          ? this.photoSessionGuid
          : photoSessionGuid as String?,
      idempotencyKey: identical(idempotencyKey, _unset)
          ? this.idempotencyKey
          : idempotencyKey as String?,
      idempotencySignature: identical(idempotencySignature, _unset)
          ? this.idempotencySignature
          : idempotencySignature as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      checkType: checkType ?? this.checkType,
    );
  }
}

const Object _unset = Object();

final whitelistDetailControllerProvider =
    NotifierProvider.autoDispose<
      WhitelistDetailController,
      WhitelistDetailState
    >(WhitelistDetailController.new);

class WhitelistDetailController extends Notifier<WhitelistDetailState> {
  static const Uuid _uuid = Uuid();

  @override
  WhitelistDetailState build() => const WhitelistDetailState();

  Future<void> load({
    required String entity,
    required String vehiclePlate,
    required String checkType,
  }) async {
    final normalizedEntity = entity.trim();
    final normalizedVehiclePlate = vehiclePlate.trim();
    final normalizedCheckType = checkType.trim().toUpperCase();
    final photoSessionGuid = state.photoSessionGuid ?? _uuid.v4();
    if (normalizedEntity.isEmpty || normalizedVehiclePlate.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: 'Missing whitelist detail identifiers.',
        checkType: normalizedCheckType,
        photoSessionGuid: photoSessionGuid,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      checkType: normalizedCheckType,
      photoSessionGuid: photoSessionGuid,
    );

    try {
      final useCase = ref.read(getWhitelistDetailUseCaseProvider);
      final detail = await useCase(
        entity: normalizedEntity,
        vehiclePlate: normalizedVehiclePlate,
      );
      state = state.copyWith(
        detail: detail,
        isLoading: false,
        errorMessage: null,
        hasLoaded: true,
        checkType: normalizedCheckType,
        photoSessionGuid: photoSessionGuid,
        idempotencyKey: null,
        idempotencySignature: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: toDisplayErrorMessage(
          error,
          fallback: 'Failed to load whitelist detail.',
        ),
        hasLoaded: true,
        checkType: normalizedCheckType,
        photoSessionGuid: photoSessionGuid,
      );
    }
  }

  Future<WhitelistSubmitResultEntity> submit() async {
    if (state.isSubmitting || state.isLoading) {
      return const WhitelistSubmitResultEntity(
        status: false,
        message: 'Submission is currently in progress.',
      );
    }

    final detail = state.detail;
    final vehiclePlate = detail?.vehiclePlate.trim() ?? '';
    if (detail == null || vehiclePlate.isEmpty) {
      return const WhitelistSubmitResultEntity(
        status: false,
        message: 'Please load whitelist detail before submit.',
      );
    }

    final session = await ref.read(authLocalDataSourceProvider).getSession();
    final entity = session?.entity.trim() ?? '';
    final site = session?.defaultSite.trim() ?? '';
    final gate = session?.defaultGate.trim() ?? '';
    final createdBy = session?.username.trim() ?? '';
    final isCheckOut = state.checkType.trim().toUpperCase() == 'O';
    if (entity.isEmpty || site.isEmpty || gate.isEmpty || createdBy.isEmpty) {
      return WhitelistSubmitResultEntity(
        status: false,
        message: isCheckOut
            ? 'Please login again to submit whitelist check-out.'
            : 'Please login again to submit whitelist check-in.',
      );
    }

    final submission = WhitelistSubmitEntity(
      entity: entity,
      site: site,
      gate: gate,
      vehiclePlate: vehiclePlate,
      createdBy: createdBy,
    );
    final signature = [
      state.checkType.trim().toUpperCase(),
      entity,
      site,
      gate,
      vehiclePlate,
      createdBy,
    ].join('|');

    final idempotencyKey = state.idempotencySignature == signature
        ? (state.idempotencyKey ?? _uuid.v4())
        : _uuid.v4();

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      idempotencyKey: idempotencyKey,
      idempotencySignature: signature,
    );

    try {
      final result = isCheckOut
          ? await ref.read(submitWhitelistCheckOutUseCaseProvider)(
              submission: submission,
              idempotencyKey: idempotencyKey,
            )
          : await ref.read(submitWhitelistCheckInUseCaseProvider)(
              submission: submission,
              idempotencyKey: idempotencyKey,
            );
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: isCheckOut
            ? 'Failed to submit whitelist check-out.'
            : 'Failed to submit whitelist check-in.',
      );
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return WhitelistSubmitResultEntity(status: false, message: message);
    }
  }

  Future<WhitelistSavePhotoResultEntity> savePhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) async {
    if (state.isUploadingPhoto) {
      return const WhitelistSavePhotoResultEntity(
        success: false,
        message: 'Photo upload is currently in progress.',
        photoId: null,
      );
    }

    state = state.copyWith(isUploadingPhoto: true, errorMessage: null);

    try {
      final useCase = ref.read(saveWhitelistPhotoUseCaseProvider);
      final result = await useCase(submission: submission);
      state = state.copyWith(isUploadingPhoto: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to upload whitelist photo.',
      );
      state = state.copyWith(isUploadingPhoto: false, errorMessage: message);
      return WhitelistSavePhotoResultEntity(
        success: false,
        message: message,
        photoId: null,
      );
    }
  }

  Future<WhitelistDeletePhotoResultEntity> deletePhoto({
    required int photoId,
  }) async {
    if (photoId <= 0) {
      return const WhitelistDeletePhotoResultEntity(
        success: false,
        message: 'Invalid photo id.',
      );
    }
    if (state.isDeletingPhoto && state.deletingPhotoId == photoId) {
      return const WhitelistDeletePhotoResultEntity(
        success: false,
        message: 'Photo deletion is currently in progress.',
      );
    }

    state = state.copyWith(
      isDeletingPhoto: true,
      deletingPhotoId: photoId,
      errorMessage: null,
    );

    try {
      final useCase = ref.read(deleteWhitelistPhotoUseCaseProvider);
      final result = await useCase(photoId: photoId);
      state = state.copyWith(isDeletingPhoto: false, deletingPhotoId: null);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to delete whitelist photo.',
      );
      state = state.copyWith(
        isDeletingPhoto: false,
        deletingPhotoId: null,
        errorMessage: message,
      );
      return WhitelistDeletePhotoResultEntity(success: false, message: message);
    }
  }
}

@immutable
class WhitelistGalleryPhotoKey {
  const WhitelistGalleryPhotoKey({required this.photoId});

  final int photoId;

  String get cacheKey => galleryPhotoCacheKey(photoId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhitelistGalleryPhotoKey && other.photoId == photoId;

  @override
  int get hashCode => photoId.hashCode;
}

final whitelistGalleryLocalItemsProvider =
    NotifierProvider.autoDispose<
      WhitelistGalleryLocalItemsController,
      Map<String, List<WhitelistGalleryItemEntity>>
    >(WhitelistGalleryLocalItemsController.new);

class WhitelistGalleryLocalItemsController
    extends Notifier<Map<String, List<WhitelistGalleryItemEntity>>> {
  @override
  Map<String, List<WhitelistGalleryItemEntity>> build() =>
      <String, List<WhitelistGalleryItemEntity>>{};

  void append({
    required String guid,
    required WhitelistGalleryItemEntity item,
  }) {
    final key = guid.trim();
    if (key.isEmpty) {
      return;
    }
    final next = <String, List<WhitelistGalleryItemEntity>>{...state};
    final current = next[key] ?? const <WhitelistGalleryItemEntity>[];
    next[key] = <WhitelistGalleryItemEntity>[...current, item];
    state = next;
  }

  void remove({required String guid, required int photoId}) {
    final key = guid.trim();
    if (key.isEmpty || photoId <= 0) {
      return;
    }

    final current = state[key];
    if (current == null || current.isEmpty) {
      return;
    }

    final filtered = current
        .where((item) => item.photoId != photoId)
        .toList(growable: false);
    final next = <String, List<WhitelistGalleryItemEntity>>{...state};
    if (filtered.isEmpty) {
      next.remove(key);
    } else {
      next[key] = filtered;
    }
    state = next;
  }
}

final whitelistGalleryDeletedPhotoIdsProvider =
    NotifierProvider.autoDispose<
      WhitelistGalleryDeletedPhotoIdsController,
      Map<String, Set<int>>
    >(WhitelistGalleryDeletedPhotoIdsController.new);

class WhitelistGalleryDeletedPhotoIdsController
    extends Notifier<Map<String, Set<int>>> {
  @override
  Map<String, Set<int>> build() => <String, Set<int>>{};

  void markDeleted({required String guid, required int photoId}) {
    final key = guid.trim();
    if (key.isEmpty || photoId <= 0) {
      return;
    }
    final next = <String, Set<int>>{...state};
    final current = <int>{...(next[key] ?? const <int>{})};
    current.add(photoId);
    next[key] = current;
    state = next;
  }
}

final whitelistGalleryPhotoCacheProvider = Provider<Map<String, Uint8List?>>((
  ref,
) {
  return <String, Uint8List?>{};
});

final whitelistGalleryListProvider = FutureProvider.autoDispose
    .family<List<WhitelistGalleryItemEntity>, String>((ref, guid) async {
      final normalizedGuid = guid.trim();
      if (normalizedGuid.isEmpty) {
        return const <WhitelistGalleryItemEntity>[];
      }

      final repository = ref.read(whitelistRepositoryProvider);
      return repository.getWhitelistGalleryList(guid: normalizedGuid);
    });

final whitelistGalleryPhotoProvider = FutureProvider.autoDispose
    .family<Uint8List?, WhitelistGalleryPhotoKey>((ref, key) async {
      if (key.photoId <= 0) {
        return null;
      }

      final cache = ref.read(whitelistGalleryPhotoCacheProvider);
      final repository = ref.read(whitelistRepositoryProvider);
      return fetchPhotoWithMemoryCache(
        cache: cache,
        cacheKey: key.cacheKey,
        loader: () => repository.getWhitelistPhoto(photoId: key.photoId),
      );
    });

void seedWhitelistGalleryPhotoCache(
  WidgetRef ref, {
  required int photoId,
  required Uint8List bytes,
}) {
  final cache = ref.read(whitelistGalleryPhotoCacheProvider);
  seedPhotoMemoryCache(
    cache,
    cacheKey: galleryPhotoCacheKey(photoId),
    bytes: bytes,
  );
}

void removeWhitelistGalleryPhotoCache(WidgetRef ref, {required int photoId}) {
  final cache = ref.read(whitelistGalleryPhotoCacheProvider);
  removePhotoMemoryCache(cache, cacheKey: galleryPhotoCacheKey(photoId));
}
