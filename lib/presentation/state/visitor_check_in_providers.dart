import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/visitor_access_remote_data_source.dart';
import '../../data/repositories/visitor_access_repository_impl.dart';
import '../../domain/entities/visitor_check_in_result_entity.dart';
import '../../domain/entities/visitor_check_in_submission_entity.dart';
import '../../domain/entities/visitor_gallery_item_entity.dart';
import '../../domain/entities/visitor_lookup_entity.dart';
import '../../domain/entities/visitor_save_photo_result_entity.dart';
import '../../domain/entities/visitor_save_photo_submission_entity.dart';
import '../../domain/repositories/visitor_access_repository.dart';
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

@immutable
class VisitorCheckState {
  const VisitorCheckState({
    this.searchInput = '',
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUploadingPhoto = false,
    this.errorMessage,
    this.lookup,
  });

  final String searchInput;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUploadingPhoto;
  final String? errorMessage;
  final VisitorLookupEntity? lookup;

  VisitorCheckState copyWith({
    String? searchInput,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUploadingPhoto,
    Object? errorMessage = _unset,
    Object? lookup = _unset,
  }) {
    return VisitorCheckState(
      searchInput: searchInput ?? this.searchInput,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
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
      final text = error.toString().trim();
      state = state.copyWith(
        isLoading: false,
        errorMessage: text.startsWith('Exception:')
            ? text.replaceFirst('Exception:', '').trim()
            : (text.isEmpty ? 'Failed to load visitor check data.' : text),
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
      final text = error.toString().trim();
      final message = text.startsWith('Exception:')
          ? text.replaceFirst('Exception:', '').trim()
          : (text.isEmpty ? 'Failed to submit visitor check-in.' : text);
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
      final text = error.toString().trim();
      final message = text.startsWith('Exception:')
          ? text.replaceFirst('Exception:', '').trim()
          : (text.isEmpty ? 'Failed to submit visitor check-out.' : text);
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
      final text = error.toString().trim();
      final message = text.startsWith('Exception:')
          ? text.replaceFirst('Exception:', '').trim()
          : (text.isEmpty ? 'Failed to upload visitor photo.' : text);
      state = state.copyWith(isUploadingPhoto: false, errorMessage: message);
      return VisitorSavePhotoResultEntity(
        success: false,
        message: message,
        photoId: null,
      );
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

  String get cacheKey => 'gallery-photo-$photoId';

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
}

final visitorGalleryListProvider = FutureProvider.autoDispose
    .family<List<VisitorGalleryItemEntity>, String>((ref, invitationId) async {
      final normalizedInvitationId = invitationId.trim();
      if (normalizedInvitationId.isEmpty) {
        return const <VisitorGalleryItemEntity>[];
      }

      final repository = ref.read(visitorAccessRepositoryProvider);
      final remoteItems = await repository.getVisitorGalleryList(
        invitationId: normalizedInvitationId,
      );
      final localItems = ref.watch(
        visitorGalleryLocalItemsProvider.select(
          (map) =>
              map[normalizedInvitationId] ?? const <VisitorGalleryItemEntity>[],
        ),
      );

      if (localItems.isEmpty) {
        return remoteItems;
      }

      final seen = <int>{};
      final merged = <VisitorGalleryItemEntity>[];
      for (final item in [...localItems, ...remoteItems]) {
        if (seen.add(item.photoId)) {
          merged.add(item);
        }
      }
      return merged;
    });

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
  if (photoId <= 0 || bytes.isEmpty) {
    return;
  }
  final cache = ref.read(visitorGalleryPhotoCacheProvider);
  cache['gallery-photo-$photoId'] = bytes;
}
