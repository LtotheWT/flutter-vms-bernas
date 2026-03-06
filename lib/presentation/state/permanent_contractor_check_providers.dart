import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/permanent_contractor_delete_photo_result_entity.dart';
import '../../domain/entities/permanent_contractor_gallery_item_entity.dart';
import '../../domain/entities/permanent_contractor_info_entity.dart';
import '../../domain/entities/permanent_contractor_save_photo_result_entity.dart';
import '../../domain/entities/permanent_contractor_save_photo_submission_entity.dart';
import '../../domain/entities/permanent_contractor_submit_entity.dart';
import '../../domain/entities/permanent_contractor_submit_result_entity.dart';
import '../../domain/usecases/delete_permanent_contractor_gallery_photo_usecase.dart';
import '../../domain/usecases/get_permanent_contractor_info_usecase.dart';
import '../../domain/usecases/save_permanent_contractor_photo_usecase.dart';
import '../../domain/usecases/submit_permanent_contractor_check_in_usecase.dart';
import '../../domain/usecases/submit_permanent_contractor_check_out_usecase.dart';
import 'auth_session_providers.dart';
import 'reference_providers.dart';
import 'photo_cache_helpers.dart';

enum PermanentContractorCheckType { checkIn, checkOut }

final getPermanentContractorInfoUseCaseProvider =
    Provider<GetPermanentContractorInfoUseCase>((ref) {
      final repository = ref.read(referenceRepositoryProvider);
      return GetPermanentContractorInfoUseCase(repository);
    });

final submitPermanentContractorCheckInUseCaseProvider =
    Provider<SubmitPermanentContractorCheckInUseCase>((ref) {
      final repository = ref.read(referenceRepositoryProvider);
      return SubmitPermanentContractorCheckInUseCase(repository);
    });

final submitPermanentContractorCheckOutUseCaseProvider =
    Provider<SubmitPermanentContractorCheckOutUseCase>((ref) {
      final repository = ref.read(referenceRepositoryProvider);
      return SubmitPermanentContractorCheckOutUseCase(repository);
    });

final savePermanentContractorPhotoUseCaseProvider =
    Provider<SavePermanentContractorPhotoUseCase>((ref) {
      final repository = ref.read(referenceRepositoryProvider);
      return SavePermanentContractorPhotoUseCase(repository);
    });

final deletePermanentContractorGalleryPhotoUseCaseProvider =
    Provider<DeletePermanentContractorGalleryPhotoUseCase>((ref) {
      final repository = ref.read(referenceRepositoryProvider);
      return DeletePermanentContractorGalleryPhotoUseCase(repository);
    });

@immutable
class PermanentContractorCheckState {
  const PermanentContractorCheckState({
    this.checkType = PermanentContractorCheckType.checkIn,
    this.searchInput = '',
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUploadingPhoto = false,
    this.isDeletingPhoto = false,
    this.deletingPhotoId,
    this.photoSessionGuid = '',
    this.idempotencyKey,
    this.idempotencySignature,
    this.errorMessage,
    this.info,
  });

  final PermanentContractorCheckType checkType;
  final String searchInput;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUploadingPhoto;
  final bool isDeletingPhoto;
  final int? deletingPhotoId;
  final String photoSessionGuid;
  final String? idempotencyKey;
  final String? idempotencySignature;
  final String? errorMessage;
  final PermanentContractorInfoEntity? info;

  PermanentContractorCheckState copyWith({
    PermanentContractorCheckType? checkType,
    String? searchInput,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUploadingPhoto,
    bool? isDeletingPhoto,
    Object? deletingPhotoId = _unset,
    String? photoSessionGuid,
    Object? idempotencyKey = _unset,
    Object? idempotencySignature = _unset,
    Object? errorMessage = _unset,
    Object? info = _unset,
  }) {
    return PermanentContractorCheckState(
      checkType: checkType ?? this.checkType,
      searchInput: searchInput ?? this.searchInput,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isDeletingPhoto: isDeletingPhoto ?? this.isDeletingPhoto,
      deletingPhotoId: identical(deletingPhotoId, _unset)
          ? this.deletingPhotoId
          : deletingPhotoId as int?,
      photoSessionGuid: photoSessionGuid ?? this.photoSessionGuid,
      idempotencyKey: identical(idempotencyKey, _unset)
          ? this.idempotencyKey
          : idempotencyKey as String?,
      idempotencySignature: identical(idempotencySignature, _unset)
          ? this.idempotencySignature
          : idempotencySignature as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      info: identical(info, _unset)
          ? this.info
          : info as PermanentContractorInfoEntity?,
    );
  }
}

const Object _unset = Object();

final permanentContractorCheckControllerProvider =
    NotifierProvider.autoDispose<
      PermanentContractorCheckController,
      PermanentContractorCheckState
    >(PermanentContractorCheckController.new);

class PermanentContractorCheckController
    extends Notifier<PermanentContractorCheckState> {
  static const Uuid _uuid = Uuid();

  @override
  PermanentContractorCheckState build() =>
      PermanentContractorCheckState(photoSessionGuid: _uuid.v4());

  void setCheckType(PermanentContractorCheckType value) {
    if (state.checkType == value) {
      return;
    }
    state = state.copyWith(
      checkType: value,
      idempotencyKey: null,
      idempotencySignature: null,
      errorMessage: null,
    );
  }

  void updateSearchInput(String value) {
    if (state.searchInput == value) {
      return;
    }
    state = state.copyWith(searchInput: value, errorMessage: null);
  }

  void clearResult() {
    state = state.copyWith(
      info: null,
      errorMessage: null,
      idempotencyKey: null,
      idempotencySignature: null,
    );
  }

  Future<bool> search() async {
    if (state.isLoading) {
      return false;
    }

    final code = state.searchInput.trim();
    if (code.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please input or scan contractor code.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final useCase = ref.read(getPermanentContractorInfoUseCaseProvider);
      final previousContractorId = state.info?.contractorId.trim() ?? '';
      final info = await useCase(code: state.searchInput);
      final nextContractorId = info.contractorId.trim();
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        info: info,
        searchInput: '',
        idempotencyKey: previousContractorId == nextContractorId
            ? state.idempotencyKey
            : null,
        idempotencySignature: previousContractorId == nextContractorId
            ? state.idempotencySignature
            : null,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: toDisplayErrorMessage(
          error,
          fallback: 'Failed to load permanent contractor info.',
        ),
      );
      return false;
    }
  }

  Future<PermanentContractorSubmitResultEntity> submitCheckIn() {
    return _submitForType(PermanentContractorCheckType.checkIn);
  }

  Future<PermanentContractorSubmitResultEntity> submitCheckOut() {
    return _submitForType(PermanentContractorCheckType.checkOut);
  }

  Future<PermanentContractorSubmitResultEntity> _submitForType(
    PermanentContractorCheckType type,
  ) async {
    if (state.isSubmitting || state.isLoading) {
      return const PermanentContractorSubmitResultEntity(
        status: false,
        message: 'Submission is currently in progress.',
      );
    }

    final info = state.info;
    final contractorId = info?.contractorId.trim() ?? '';
    if (contractorId.isEmpty) {
      return const PermanentContractorSubmitResultEntity(
        status: false,
        message: 'Please search contractor info before submit.',
      );
    }

    final session = await ref.read(authLocalDataSourceProvider).getSession();
    final createdBy = session?.username.trim() ?? '';
    final site = session?.defaultSite.trim() ?? '';
    final gate = session?.defaultGate.trim() ?? '';
    if (createdBy.isEmpty || site.isEmpty || gate.isEmpty) {
      return PermanentContractorSubmitResultEntity(
        status: false,
        message: type == PermanentContractorCheckType.checkIn
            ? 'Please login again to submit permanent contractor check-in.'
            : 'Please login again to submit permanent contractor check-out.',
      );
    }

    final submission = PermanentContractorSubmitEntity(
      contractorId: contractorId,
      site: site,
      gate: gate,
      createdBy: createdBy,
    );
    final signature = [
      type == PermanentContractorCheckType.checkOut ? 'O' : 'I',
      contractorId,
      site,
      gate,
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
      final result = type == PermanentContractorCheckType.checkIn
          ? await ref.read(submitPermanentContractorCheckInUseCaseProvider)(
              submission: submission,
              idempotencyKey: idempotencyKey,
            )
          : await ref.read(submitPermanentContractorCheckOutUseCaseProvider)(
              submission: submission,
              idempotencyKey: idempotencyKey,
            );
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: type == PermanentContractorCheckType.checkIn
            ? 'Failed to submit permanent contractor check-in.'
            : 'Failed to submit permanent contractor check-out.',
      );
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return PermanentContractorSubmitResultEntity(
        status: false,
        message: message,
      );
    }
  }

  Future<PermanentContractorSavePhotoResultEntity> savePhoto({
    required PermanentContractorSavePhotoSubmissionEntity submission,
  }) async {
    if (state.isUploadingPhoto) {
      return const PermanentContractorSavePhotoResultEntity(
        success: false,
        message: 'Photo upload is currently in progress.',
        photoId: null,
      );
    }

    state = state.copyWith(isUploadingPhoto: true, errorMessage: null);

    try {
      final useCase = ref.read(savePermanentContractorPhotoUseCaseProvider);
      final result = await useCase(submission: submission);
      state = state.copyWith(isUploadingPhoto: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to upload permanent contractor photo.',
      );
      state = state.copyWith(isUploadingPhoto: false, errorMessage: message);
      return PermanentContractorSavePhotoResultEntity(
        success: false,
        message: message,
        photoId: null,
      );
    }
  }

  Future<PermanentContractorDeletePhotoResultEntity> deletePhoto({
    required int photoId,
  }) async {
    if (photoId <= 0) {
      return const PermanentContractorDeletePhotoResultEntity(
        success: false,
        message: 'Invalid photo id.',
      );
    }
    if (state.isDeletingPhoto && state.deletingPhotoId == photoId) {
      return const PermanentContractorDeletePhotoResultEntity(
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
      final useCase = ref.read(
        deletePermanentContractorGalleryPhotoUseCaseProvider,
      );
      final result = await useCase(photoId: photoId);
      state = state.copyWith(isDeletingPhoto: false, deletingPhotoId: null);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to delete permanent contractor photo.',
      );
      state = state.copyWith(
        isDeletingPhoto: false,
        deletingPhotoId: null,
        errorMessage: message,
      );
      return PermanentContractorDeletePhotoResultEntity(
        success: false,
        message: message,
      );
    }
  }

  void resetAfterSuccessfulSubmit() {
    final previousGuid = state.photoSessionGuid.trim();
    final previousGalleryItems = previousGuid.isEmpty
        ? const <PermanentContractorGalleryItemEntity>[]
        : ref
                  .read(permanentContractorGalleryListProvider(previousGuid))
                  .maybeWhen(data: (items) => items, orElse: () => null) ??
              const <PermanentContractorGalleryItemEntity>[];
    final previousLocalItems =
        ref.read(permanentContractorGalleryLocalItemsProvider)[previousGuid] ??
        const <PermanentContractorGalleryItemEntity>[];
    final previousDeletedPhotoIds =
        ref.read(
          permanentContractorGalleryDeletedPhotoIdsProvider,
        )[previousGuid] ??
        const <int>{};

    final galleryPhotoCache = ref.read(
      permanentContractorGalleryPhotoCacheProvider,
    );
    final photoIdsToClear = <int>{
      ...previousGalleryItems.map((item) => item.photoId),
      ...previousLocalItems.map((item) => item.photoId),
      ...previousDeletedPhotoIds,
    };
    for (final photoId in photoIdsToClear) {
      removePhotoMemoryCache(
        galleryPhotoCache,
        cacheKey: galleryPhotoCacheKey(photoId),
      );
    }

    if (previousGuid.isNotEmpty) {
      ref
          .read(permanentContractorGalleryLocalItemsProvider.notifier)
          .clearGuid(guid: previousGuid);
      ref
          .read(permanentContractorGalleryDeletedPhotoIdsProvider.notifier)
          .clearGuid(guid: previousGuid);
      ref.invalidate(permanentContractorGalleryListProvider(previousGuid));
    }

    state = state.copyWith(
      searchInput: '',
      info: null,
      isSubmitting: false,
      isUploadingPhoto: false,
      isDeletingPhoto: false,
      deletingPhotoId: null,
      photoSessionGuid: _uuid.v4(),
      idempotencyKey: null,
      idempotencySignature: null,
      errorMessage: null,
    );
  }
}

@immutable
class PermanentContractorPhotoKey extends Equatable {
  const PermanentContractorPhotoKey({required this.contractorId});

  final String contractorId;

  String get cacheKey => contractorId.trim();

  @override
  List<Object?> get props => [contractorId];
}

final permanentContractorPhotoCacheProvider = Provider<Map<String, Uint8List?>>(
  (ref) => <String, Uint8List?>{},
);

final permanentContractorImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, PermanentContractorPhotoKey>((ref, key) async {
      final contractorId = key.contractorId.trim();
      if (contractorId.isEmpty) {
        return null;
      }

      final cache = ref.read(permanentContractorPhotoCacheProvider);
      final repository = ref.read(referenceRepositoryProvider);
      return fetchPhotoWithMemoryCache(
        cache: cache,
        cacheKey: key.cacheKey,
        loader: () =>
            repository.getPermanentContractorImage(contractorId: contractorId),
      );
    });

@immutable
class PermanentContractorGalleryPhotoKey extends Equatable {
  const PermanentContractorGalleryPhotoKey({required this.photoId});

  final int photoId;

  String get cacheKey => galleryPhotoCacheKey(photoId);

  @override
  List<Object?> get props => [photoId];
}

final permanentContractorGalleryLocalItemsProvider =
    NotifierProvider.autoDispose<
      PermanentContractorGalleryLocalItemsController,
      Map<String, List<PermanentContractorGalleryItemEntity>>
    >(PermanentContractorGalleryLocalItemsController.new);

class PermanentContractorGalleryLocalItemsController
    extends Notifier<Map<String, List<PermanentContractorGalleryItemEntity>>> {
  @override
  Map<String, List<PermanentContractorGalleryItemEntity>> build() =>
      <String, List<PermanentContractorGalleryItemEntity>>{};

  void append({
    required String guid,
    required PermanentContractorGalleryItemEntity item,
  }) {
    final key = guid.trim();
    if (key.isEmpty) {
      return;
    }
    final next = <String, List<PermanentContractorGalleryItemEntity>>{...state};
    final current = next[key] ?? const <PermanentContractorGalleryItemEntity>[];
    next[key] = <PermanentContractorGalleryItemEntity>[...current, item];
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
    final next = <String, List<PermanentContractorGalleryItemEntity>>{...state};
    if (filtered.isEmpty) {
      next.remove(key);
    } else {
      next[key] = filtered;
    }
    state = next;
  }

  void clearGuid({required String guid}) {
    final key = guid.trim();
    if (key.isEmpty || !state.containsKey(key)) {
      return;
    }
    final next = <String, List<PermanentContractorGalleryItemEntity>>{...state};
    next.remove(key);
    state = next;
  }
}

final permanentContractorGalleryDeletedPhotoIdsProvider =
    NotifierProvider.autoDispose<
      PermanentContractorGalleryDeletedPhotoIdsController,
      Map<String, Set<int>>
    >(PermanentContractorGalleryDeletedPhotoIdsController.new);

class PermanentContractorGalleryDeletedPhotoIdsController
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

  void clearGuid({required String guid}) {
    final key = guid.trim();
    if (key.isEmpty || !state.containsKey(key)) {
      return;
    }
    final next = <String, Set<int>>{...state};
    next.remove(key);
    state = next;
  }
}

final permanentContractorGalleryPhotoCacheProvider =
    Provider<Map<String, Uint8List?>>((ref) => <String, Uint8List?>{});

final permanentContractorGalleryListProvider = FutureProvider.autoDispose
    .family<List<PermanentContractorGalleryItemEntity>, String>((
      ref,
      guid,
    ) async {
      final normalizedGuid = guid.trim();
      if (normalizedGuid.isEmpty) {
        return const <PermanentContractorGalleryItemEntity>[];
      }

      final repository = ref.read(referenceRepositoryProvider);
      return repository.getPermanentContractorGalleryList(guid: normalizedGuid);
    });

final permanentContractorGalleryPhotoProvider = FutureProvider.autoDispose
    .family<Uint8List?, PermanentContractorGalleryPhotoKey>((ref, key) async {
      if (key.photoId <= 0) {
        return null;
      }

      final cache = ref.read(permanentContractorGalleryPhotoCacheProvider);
      final repository = ref.read(referenceRepositoryProvider);
      return fetchPhotoWithMemoryCache(
        cache: cache,
        cacheKey: key.cacheKey,
        loader: () =>
            repository.getPermanentContractorGalleryPhoto(photoId: key.photoId),
      );
    });

void seedPermanentContractorGalleryPhotoCache(
  WidgetRef ref, {
  required int photoId,
  required Uint8List bytes,
}) {
  final cache = ref.read(permanentContractorGalleryPhotoCacheProvider);
  seedPhotoMemoryCache(
    cache,
    cacheKey: galleryPhotoCacheKey(photoId),
    bytes: bytes,
  );
}

void removePermanentContractorGalleryPhotoCache(
  WidgetRef ref, {
  required int photoId,
}) {
  final cache = ref.read(permanentContractorGalleryPhotoCacheProvider);
  removePhotoMemoryCache(cache, cacheKey: galleryPhotoCacheKey(photoId));
}
