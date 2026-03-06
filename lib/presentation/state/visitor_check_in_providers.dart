import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../data/datasources/visitor_access_remote_data_source.dart';
import '../../data/repositories/visitor_access_repository_impl.dart';
import '../../domain/entities/visitor_check_in_result_entity.dart';
import '../../domain/entities/visitor_check_in_submission_entity.dart';
import '../../domain/entities/visitor_delete_photo_result_entity.dart';
import '../../domain/entities/visitor_gallery_item_entity.dart';
import '../../domain/entities/visitor_lookup_entity.dart';
import '../../domain/entities/visitor_save_photo_result_entity.dart';
import '../../domain/entities/visitor_save_photo_submission_entity.dart';
import '../../domain/repositories/visitor_access_repository.dart';
import '../../domain/usecases/delete_visitor_gallery_photo_usecase.dart';
import '../../domain/usecases/get_visitor_lookup_usecase.dart';
import '../../domain/usecases/save_visitor_photo_usecase.dart';
import '../../domain/usecases/submit_visitor_check_in_usecase.dart';
import '../../domain/usecases/submit_visitor_check_out_usecase.dart';
import 'auth_session_providers.dart';
import 'photo_cache_helpers.dart';

final visitorAccessRemoteDataSourceProvider =
    Provider<VisitorAccessRemoteDataSource>((ref) {
      final dio = ref.read(dioClientProvider);
      return VisitorAccessRemoteDataSource(dio);
    });

final visitorAccessRepositoryProvider = Provider<VisitorAccessRepository>((
  ref,
) {
  final remoteDataSource = ref.read(visitorAccessRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return VisitorAccessRepositoryImpl(remoteDataSource, localDataSource);
});

final getVisitorLookupUseCaseProvider = Provider<GetVisitorLookupUseCase>((
  ref,
) {
  final repository = ref.read(visitorAccessRepositoryProvider);
  return GetVisitorLookupUseCase(repository);
});

final submitVisitorCheckInUseCaseProvider =
    Provider<SubmitVisitorCheckInUseCase>((ref) {
      final repository = ref.read(visitorAccessRepositoryProvider);
      return SubmitVisitorCheckInUseCase(repository);
    });

final submitVisitorCheckOutUseCaseProvider =
    Provider<SubmitVisitorCheckOutUseCase>((ref) {
      final repository = ref.read(visitorAccessRepositoryProvider);
      return SubmitVisitorCheckOutUseCase(repository);
    });

final saveVisitorPhotoUseCaseProvider = Provider<SaveVisitorPhotoUseCase>((
  ref,
) {
  final repository = ref.read(visitorAccessRepositoryProvider);
  return SaveVisitorPhotoUseCase(repository);
});

final deleteVisitorGalleryPhotoUseCaseProvider =
    Provider<DeleteVisitorGalleryPhotoUseCase>((ref) {
      final repository = ref.read(visitorAccessRepositoryProvider);
      return DeleteVisitorGalleryPhotoUseCase(repository);
    });

@immutable
class VisitorCheckState {
  const VisitorCheckState({
    this.searchInput = '',
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUploadingPhoto = false,
    this.isDeletingPhoto = false,
    this.deletingPhotoId,
    this.errorMessage,
    this.lookup,
  });

  final String searchInput;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUploadingPhoto;
  final bool isDeletingPhoto;
  final int? deletingPhotoId;
  final String? errorMessage;
  final VisitorLookupEntity? lookup;

  VisitorCheckState copyWith({
    String? searchInput,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUploadingPhoto,
    bool? isDeletingPhoto,
    Object? deletingPhotoId = _unset,
    Object? errorMessage = _unset,
    Object? lookup = _unset,
  }) {
    return VisitorCheckState(
      searchInput: searchInput ?? this.searchInput,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isDeletingPhoto: isDeletingPhoto ?? this.isDeletingPhoto,
      deletingPhotoId: identical(deletingPhotoId, _unset)
          ? this.deletingPhotoId
          : deletingPhotoId as int?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      lookup: identical(lookup, _unset)
          ? this.lookup
          : lookup as VisitorLookupEntity?,
    );
  }
}

const Object _unset = Object();

final visitorCheckControllerProvider =
    NotifierProvider.autoDispose<VisitorCheckController, VisitorCheckState>(
      VisitorCheckController.new,
    );

class VisitorCheckController extends Notifier<VisitorCheckState> {
  @override
  VisitorCheckState build() => const VisitorCheckState();

  void updateSearchInput(String value) {
    if (state.searchInput == value) {
      return;
    }
    state = state.copyWith(searchInput: value, errorMessage: null);
  }

  void clearAll() {
    state = const VisitorCheckState();
  }

  Future<bool> search({required bool isCheckIn}) async {
    if (state.isLoading || state.isSubmitting || state.isUploadingPhoto) {
      return false;
    }

    final code = state.searchInput.trim();
    if (code.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please input or scan visitor code.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final useCase = ref.read(getVisitorLookupUseCaseProvider);
      final lookup = await useCase(
        code: state.searchInput,
        isCheckIn: isCheckIn,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        lookup: lookup,
        searchInput: '',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: toDisplayErrorMessage(
          error,
          fallback: 'Failed to load visitor check data.',
        ),
      );
      return false;
    }
  }

  Future<VisitorCheckInResultEntity> submitCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    if (state.isSubmitting || state.isUploadingPhoto) {
      return const VisitorCheckInResultEntity(
        status: false,
        message: 'Check-in is currently submitting.',
      );
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final useCase = ref.read(submitVisitorCheckInUseCaseProvider);
      final result = await useCase(submission: submission);
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to submit visitor check-in.',
      );
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return VisitorCheckInResultEntity(status: false, message: message);
    }
  }

  Future<VisitorCheckInResultEntity> submitCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    if (state.isSubmitting || state.isUploadingPhoto) {
      return const VisitorCheckInResultEntity(
        status: false,
        message: 'Check-out is currently submitting.',
      );
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final useCase = ref.read(submitVisitorCheckOutUseCaseProvider);
      final result = await useCase(submission: submission);
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to submit visitor check-out.',
      );
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return VisitorCheckInResultEntity(status: false, message: message);
    }
  }

  Future<VisitorSavePhotoResultEntity> savePhoto({
    required VisitorSavePhotoSubmissionEntity submission,
  }) async {
    if (state.isUploadingPhoto || state.isSubmitting) {
      return const VisitorSavePhotoResultEntity(
        success: false,
        message: 'Photo upload is currently in progress.',
        photoId: null,
      );
    }

    state = state.copyWith(isUploadingPhoto: true, errorMessage: null);

    try {
      final useCase = ref.read(saveVisitorPhotoUseCaseProvider);
      final result = await useCase(submission: submission);
      state = state.copyWith(isUploadingPhoto: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to upload visitor photo.',
      );
      state = state.copyWith(isUploadingPhoto: false, errorMessage: message);
      return VisitorSavePhotoResultEntity(
        success: false,
        message: message,
        photoId: null,
      );
    }
  }

  Future<VisitorDeletePhotoResultEntity> deletePhoto({
    required int photoId,
  }) async {
    if (photoId <= 0) {
      return const VisitorDeletePhotoResultEntity(
        success: false,
        message: 'Invalid photo id.',
      );
    }
    if (state.isDeletingPhoto && state.deletingPhotoId == photoId) {
      return const VisitorDeletePhotoResultEntity(
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
      final useCase = ref.read(deleteVisitorGalleryPhotoUseCaseProvider);
      final result = await useCase(photoId: photoId);
      state = state.copyWith(isDeletingPhoto: false, deletingPhotoId: null);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to delete gallery photo.',
      );
      state = state.copyWith(
        isDeletingPhoto: false,
        deletingPhotoId: null,
        errorMessage: message,
      );
      return VisitorDeletePhotoResultEntity(success: false, message: message);
    }
  }
}

@immutable
class VisitorPhotoKey extends Equatable {
  const VisitorPhotoKey({required this.invitationId, required this.appId});

  final String invitationId;
  final String appId;

  String get cacheKey => '${invitationId.trim()}|${appId.trim()}';

  @override
  List<Object?> get props => [invitationId, appId];
}

final visitorPhotoCacheProvider = Provider<Map<String, Uint8List?>>((ref) {
  return <String, Uint8List?>{};
});

final visitorApplicantImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, VisitorPhotoKey>((ref, key) async {
      final invitationId = key.invitationId.trim();
      final appId = key.appId.trim();
      if (invitationId.isEmpty || appId.isEmpty) {
        return null;
      }

      final cache = ref.read(visitorPhotoCacheProvider);
      final repository = ref.read(visitorAccessRepositoryProvider);
      return fetchPhotoWithMemoryCache(
        cache: cache,
        cacheKey: key.cacheKey,
        loader: () => repository.getVisitorApplicantImage(
          invitationId: invitationId,
          appId: appId,
        ),
      );
    });

@immutable
class VisitorGalleryPhotoKey extends Equatable {
  const VisitorGalleryPhotoKey({required this.photoId});

  final int photoId;

  String get cacheKey => galleryPhotoCacheKey(photoId);

  @override
  List<Object?> get props => [photoId];
}

final visitorGalleryLocalItemsProvider =
    NotifierProvider.autoDispose<
      VisitorGalleryLocalItemsController,
      Map<String, List<VisitorGalleryItemEntity>>
    >(VisitorGalleryLocalItemsController.new);

class VisitorGalleryLocalItemsController
    extends Notifier<Map<String, List<VisitorGalleryItemEntity>>> {
  @override
  Map<String, List<VisitorGalleryItemEntity>> build() {
    return <String, List<VisitorGalleryItemEntity>>{};
  }

  void append({
    required String invitationId,
    required VisitorGalleryItemEntity item,
  }) {
    final key = invitationId.trim();
    if (key.isEmpty) {
      return;
    }
    final next = <String, List<VisitorGalleryItemEntity>>{...state};
    final current = next[key] ?? const <VisitorGalleryItemEntity>[];
    next[key] = <VisitorGalleryItemEntity>[item, ...current];
    state = next;
  }

  void remove({required String invitationId, required int photoId}) {
    final key = invitationId.trim();
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
    final next = <String, List<VisitorGalleryItemEntity>>{...state};
    if (filtered.isEmpty) {
      next.remove(key);
    } else {
      next[key] = filtered;
    }
    state = next;
  }
}

final visitorGalleryListProvider = FutureProvider.autoDispose
    .family<List<VisitorGalleryItemEntity>, String>((ref, invitationId) async {
      final normalizedInvitationId = invitationId.trim();
      if (normalizedInvitationId.isEmpty) {
        return const <VisitorGalleryItemEntity>[];
      }

      final repository = ref.read(visitorAccessRepositoryProvider);
      return repository.getVisitorGalleryList(
        invitationId: normalizedInvitationId,
      );
    });

final visitorGalleryDeletedPhotoIdsProvider =
    NotifierProvider.autoDispose<
      VisitorGalleryDeletedPhotoIdsController,
      Map<String, Set<int>>
    >(VisitorGalleryDeletedPhotoIdsController.new);

class VisitorGalleryDeletedPhotoIdsController
    extends Notifier<Map<String, Set<int>>> {
  @override
  Map<String, Set<int>> build() => <String, Set<int>>{};

  void markDeleted({required String invitationId, required int photoId}) {
    final key = invitationId.trim();
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

final visitorGalleryPhotoCacheProvider = Provider<Map<String, Uint8List?>>((
  ref,
) {
  return <String, Uint8List?>{};
});

final visitorGalleryPhotoProvider = FutureProvider.autoDispose
    .family<Uint8List?, VisitorGalleryPhotoKey>((ref, key) async {
      if (key.photoId <= 0) {
        return null;
      }

      final cache = ref.read(visitorGalleryPhotoCacheProvider);
      final repository = ref.read(visitorAccessRepositoryProvider);
      return fetchPhotoWithMemoryCache(
        cache: cache,
        cacheKey: key.cacheKey,
        loader: () => repository.getVisitorGalleryPhoto(photoId: key.photoId),
      );
    });

void seedVisitorGalleryPhotoCache(
  WidgetRef ref, {
  required int photoId,
  required Uint8List bytes,
}) {
  final cache = ref.read(visitorGalleryPhotoCacheProvider);
  seedPhotoMemoryCache(
    cache,
    cacheKey: galleryPhotoCacheKey(photoId),
    bytes: bytes,
  );
}

void removeVisitorGalleryPhotoCache(WidgetRef ref, {required int photoId}) {
  final cache = ref.read(visitorGalleryPhotoCacheProvider);
  removePhotoMemoryCache(cache, cacheKey: galleryPhotoCacheKey(photoId));
}
