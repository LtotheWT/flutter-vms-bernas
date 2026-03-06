import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/employee_delete_photo_result_entity.dart';
import '../../domain/entities/employee_gallery_item_entity.dart';
import '../../data/datasources/employee_access_remote_data_source.dart';
import '../../data/repositories/employee_access_repository_impl.dart';
import '../../domain/entities/employee_info_entity.dart';
import '../../domain/entities/employee_save_photo_result_entity.dart';
import '../../domain/entities/employee_save_photo_submission_entity.dart';
import '../../domain/entities/employee_submit_entity.dart';
import '../../domain/entities/employee_submit_result_entity.dart';
import '../../domain/repositories/employee_access_repository.dart';
import '../../domain/usecases/delete_employee_gallery_photo_usecase.dart';
import '../../domain/usecases/get_employee_info_usecase.dart';
import '../../domain/usecases/save_employee_photo_usecase.dart';
import '../../domain/usecases/submit_employee_check_in_usecase.dart';
import '../../domain/usecases/submit_employee_check_out_usecase.dart';
import 'auth_session_providers.dart';
import 'photo_cache_helpers.dart';

enum EmployeeCheckType { checkIn, checkOut }

final employeeAccessRemoteDataSourceProvider =
    Provider<EmployeeAccessRemoteDataSource>((ref) {
      final dio = ref.read(dioClientProvider);
      return EmployeeAccessRemoteDataSource(dio);
    });

final employeeAccessRepositoryProvider = Provider<EmployeeAccessRepository>((
  ref,
) {
  final remoteDataSource = ref.read(employeeAccessRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return EmployeeAccessRepositoryImpl(remoteDataSource, localDataSource);
});

final getEmployeeInfoUseCaseProvider = Provider<GetEmployeeInfoUseCase>((ref) {
  final repository = ref.read(employeeAccessRepositoryProvider);
  return GetEmployeeInfoUseCase(repository);
});

final submitEmployeeCheckInUseCaseProvider =
    Provider<SubmitEmployeeCheckInUseCase>((ref) {
      final repository = ref.read(employeeAccessRepositoryProvider);
      return SubmitEmployeeCheckInUseCase(repository);
    });

final submitEmployeeCheckOutUseCaseProvider =
    Provider<SubmitEmployeeCheckOutUseCase>((ref) {
      final repository = ref.read(employeeAccessRepositoryProvider);
      return SubmitEmployeeCheckOutUseCase(repository);
    });

final saveEmployeePhotoUseCaseProvider = Provider<SaveEmployeePhotoUseCase>((
  ref,
) {
  final repository = ref.read(employeeAccessRepositoryProvider);
  return SaveEmployeePhotoUseCase(repository);
});

final deleteEmployeeGalleryPhotoUseCaseProvider =
    Provider<DeleteEmployeeGalleryPhotoUseCase>((ref) {
      final repository = ref.read(employeeAccessRepositoryProvider);
      return DeleteEmployeeGalleryPhotoUseCase(repository);
    });

@immutable
class EmployeeCheckState {
  const EmployeeCheckState({
    this.checkType = EmployeeCheckType.checkIn,
    this.searchInput = '',
    this.info,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUploadingPhoto = false,
    this.isDeletingPhoto = false,
    this.deletingPhotoId,
    this.photoSessionGuid = '',
    this.idempotencyKey,
    this.idempotencySignature,
    this.errorMessage,
  });

  final EmployeeCheckType checkType;
  final String searchInput;
  final EmployeeInfoEntity? info;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUploadingPhoto;
  final bool isDeletingPhoto;
  final int? deletingPhotoId;
  final String photoSessionGuid;
  final String? idempotencyKey;
  final String? idempotencySignature;
  final String? errorMessage;

  EmployeeCheckState copyWith({
    EmployeeCheckType? checkType,
    String? searchInput,
    Object? info = _unset,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUploadingPhoto,
    bool? isDeletingPhoto,
    Object? deletingPhotoId = _unset,
    String? photoSessionGuid,
    Object? idempotencyKey = _unset,
    Object? idempotencySignature = _unset,
    Object? errorMessage = _unset,
  }) {
    return EmployeeCheckState(
      checkType: checkType ?? this.checkType,
      searchInput: searchInput ?? this.searchInput,
      info: identical(info, _unset) ? this.info : info as EmployeeInfoEntity?,
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
    );
  }
}

const Object _unset = Object();

final employeeCheckControllerProvider =
    NotifierProvider.autoDispose<EmployeeCheckController, EmployeeCheckState>(
      EmployeeCheckController.new,
    );

class EmployeeCheckController extends Notifier<EmployeeCheckState> {
  static const Uuid _uuid = Uuid();

  @override
  EmployeeCheckState build() =>
      EmployeeCheckState(photoSessionGuid: _uuid.v4());

  void setCheckType(EmployeeCheckType value) {
    if (value == state.checkType) {
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
    if (value == state.searchInput) {
      return;
    }
    state = state.copyWith(searchInput: value, errorMessage: null);
  }

  Future<bool> search() async {
    if (state.isLoading) {
      return false;
    }

    final code = state.searchInput.trim();
    if (code.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please input or scan employee code.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final previousEmployeeId = state.info?.employeeId.trim() ?? '';
      final useCase = ref.read(getEmployeeInfoUseCaseProvider);
      final info = await useCase(code: state.searchInput);
      final nextEmployeeId = info.employeeId.trim();
      state = state.copyWith(
        isLoading: false,
        searchInput: '',
        info: info,
        errorMessage: null,
        idempotencyKey: previousEmployeeId == nextEmployeeId
            ? state.idempotencyKey
            : null,
        idempotencySignature: previousEmployeeId == nextEmployeeId
            ? state.idempotencySignature
            : null,
      );
      return true;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to load employee info.',
      );
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  Future<EmployeeSubmitResultEntity> submit() async {
    if (state.isSubmitting || state.isLoading) {
      return const EmployeeSubmitResultEntity(
        status: false,
        message: 'Submission is currently in progress.',
      );
    }

    final info = state.info;
    final employeeId = info?.employeeId.trim() ?? '';
    if (employeeId.isEmpty) {
      return const EmployeeSubmitResultEntity(
        status: false,
        message: 'Please search employee info before submit.',
      );
    }

    final session = await ref.read(authLocalDataSourceProvider).getSession();
    final site = session?.defaultSite.trim() ?? '';
    final gate = session?.defaultGate.trim() ?? '';
    final createdBy = session?.username.trim() ?? '';
    final isCheckOut = state.checkType == EmployeeCheckType.checkOut;
    if (site.isEmpty || gate.isEmpty || createdBy.isEmpty) {
      return EmployeeSubmitResultEntity(
        status: false,
        message: isCheckOut
            ? 'Please login again to submit employee check-out.'
            : 'Please login again to submit employee check-in.',
      );
    }

    final submission = EmployeeSubmitEntity(
      employeeId: employeeId,
      site: site,
      gate: gate,
      createdBy: createdBy,
    );
    final signature = [
      isCheckOut ? 'O' : 'I',
      employeeId,
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
      final result = isCheckOut
          ? await ref.read(submitEmployeeCheckOutUseCaseProvider)(
              submission: submission,
              idempotencyKey: idempotencyKey,
            )
          : await ref.read(submitEmployeeCheckInUseCaseProvider)(
              submission: submission,
              idempotencyKey: idempotencyKey,
            );
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: isCheckOut
            ? 'Failed to submit employee check-out.'
            : 'Failed to submit employee check-in.',
      );
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      return EmployeeSubmitResultEntity(status: false, message: message);
    }
  }

  Future<EmployeeSavePhotoResultEntity> savePhoto({
    required EmployeeSavePhotoSubmissionEntity submission,
  }) async {
    if (state.isUploadingPhoto) {
      return const EmployeeSavePhotoResultEntity(
        success: false,
        message: 'Photo upload is currently in progress.',
        photoId: null,
      );
    }

    state = state.copyWith(isUploadingPhoto: true, errorMessage: null);

    try {
      final useCase = ref.read(saveEmployeePhotoUseCaseProvider);
      final result = await useCase(submission: submission);
      state = state.copyWith(isUploadingPhoto: false);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to upload employee photo.',
      );
      state = state.copyWith(isUploadingPhoto: false, errorMessage: message);
      return EmployeeSavePhotoResultEntity(
        success: false,
        message: message,
        photoId: null,
      );
    }
  }

  Future<EmployeeDeletePhotoResultEntity> deletePhoto({
    required int photoId,
  }) async {
    if (photoId <= 0) {
      return const EmployeeDeletePhotoResultEntity(
        success: false,
        message: 'Invalid photo id.',
      );
    }
    if (state.isDeletingPhoto && state.deletingPhotoId == photoId) {
      return const EmployeeDeletePhotoResultEntity(
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
      final useCase = ref.read(deleteEmployeeGalleryPhotoUseCaseProvider);
      final result = await useCase(photoId: photoId);
      state = state.copyWith(isDeletingPhoto: false, deletingPhotoId: null);
      return result;
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to delete employee photo.',
      );
      state = state.copyWith(
        isDeletingPhoto: false,
        deletingPhotoId: null,
        errorMessage: message,
      );
      return EmployeeDeletePhotoResultEntity(success: false, message: message);
    }
  }

  void resetAfterSuccessfulSubmit() {
    final previousGuid = state.photoSessionGuid.trim();
    final previousGalleryItems = previousGuid.isEmpty
        ? const <EmployeeGalleryItemEntity>[]
        : ref
                  .read(employeeGalleryListProvider(previousGuid))
                  .maybeWhen(data: (items) => items, orElse: () => null) ??
              const <EmployeeGalleryItemEntity>[];
    final previousLocalItems =
        ref.read(employeeGalleryLocalItemsProvider)[previousGuid] ??
        const <EmployeeGalleryItemEntity>[];
    final previousDeletedPhotoIds =
        ref.read(employeeGalleryDeletedPhotoIdsProvider)[previousGuid] ??
        const <int>{};

    final galleryPhotoCache = ref.read(employeeGalleryPhotoCacheProvider);
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
          .read(employeeGalleryLocalItemsProvider.notifier)
          .clearGuid(guid: previousGuid);
      ref
          .read(employeeGalleryDeletedPhotoIdsProvider.notifier)
          .clearGuid(guid: previousGuid);
      ref.invalidate(employeeGalleryListProvider(previousGuid));
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
class EmployeePhotoKey extends Equatable {
  const EmployeePhotoKey({required this.employeeId});

  final String employeeId;

  String get cacheKey => employeeId.trim();

  @override
  List<Object?> get props => [employeeId];
}

final employeePhotoCacheProvider = Provider<Map<String, Uint8List?>>(
  (ref) => <String, Uint8List?>{},
);

final employeeImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, EmployeePhotoKey>((ref, key) async {
      final employeeId = key.employeeId.trim();
      if (employeeId.isEmpty) {
        return null;
      }

      final cache = ref.read(employeePhotoCacheProvider);
      final repository = ref.read(employeeAccessRepositoryProvider);
      return fetchPhotoWithMemoryCache(
        cache: cache,
        cacheKey: key.cacheKey,
        loader: () => repository.getEmployeeImage(employeeId: employeeId),
      );
    });

@immutable
class EmployeeGalleryPhotoKey extends Equatable {
  const EmployeeGalleryPhotoKey({required this.photoId});

  final int photoId;

  String get cacheKey => galleryPhotoCacheKey(photoId);

  @override
  List<Object?> get props => [photoId];
}

final employeeGalleryLocalItemsProvider =
    NotifierProvider.autoDispose<
      EmployeeGalleryLocalItemsController,
      Map<String, List<EmployeeGalleryItemEntity>>
    >(EmployeeGalleryLocalItemsController.new);

class EmployeeGalleryLocalItemsController
    extends Notifier<Map<String, List<EmployeeGalleryItemEntity>>> {
  @override
  Map<String, List<EmployeeGalleryItemEntity>> build() =>
      <String, List<EmployeeGalleryItemEntity>>{};

  void append({required String guid, required EmployeeGalleryItemEntity item}) {
    final key = guid.trim();
    if (key.isEmpty) {
      return;
    }

    final next = <String, List<EmployeeGalleryItemEntity>>{...state};
    final current = next[key] ?? const <EmployeeGalleryItemEntity>[];
    next[key] = <EmployeeGalleryItemEntity>[...current, item];
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
    final next = <String, List<EmployeeGalleryItemEntity>>{...state};
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
    final next = <String, List<EmployeeGalleryItemEntity>>{...state};
    next.remove(key);
    state = next;
  }
}

final employeeGalleryDeletedPhotoIdsProvider =
    NotifierProvider.autoDispose<
      EmployeeGalleryDeletedPhotoIdsController,
      Map<String, Set<int>>
    >(EmployeeGalleryDeletedPhotoIdsController.new);

class EmployeeGalleryDeletedPhotoIdsController
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

final employeeGalleryPhotoCacheProvider = Provider<Map<String, Uint8List?>>((
  ref,
) {
  return <String, Uint8List?>{};
});

final employeeGalleryListProvider = FutureProvider.autoDispose
    .family<List<EmployeeGalleryItemEntity>, String>((ref, guid) async {
      final normalizedGuid = guid.trim();
      if (normalizedGuid.isEmpty) {
        return const <EmployeeGalleryItemEntity>[];
      }

      final repository = ref.read(employeeAccessRepositoryProvider);
      return repository.getEmployeeGalleryList(guid: normalizedGuid);
    });

final employeeGalleryPhotoProvider = FutureProvider.autoDispose
    .family<Uint8List?, EmployeeGalleryPhotoKey>((ref, key) async {
      if (key.photoId <= 0) {
        return null;
      }

      final cache = ref.read(employeeGalleryPhotoCacheProvider);
      final repository = ref.read(employeeAccessRepositoryProvider);
      return fetchPhotoWithMemoryCache(
        cache: cache,
        cacheKey: key.cacheKey,
        loader: () => repository.getEmployeeGalleryPhoto(photoId: key.photoId),
      );
    });

void seedEmployeeGalleryPhotoCache(
  WidgetRef ref, {
  required int photoId,
  required Uint8List bytes,
}) {
  final cache = ref.read(employeeGalleryPhotoCacheProvider);
  seedPhotoMemoryCache(
    cache,
    cacheKey: galleryPhotoCacheKey(photoId),
    bytes: bytes,
  );
}

void removeEmployeeGalleryPhotoCache(WidgetRef ref, {required int photoId}) {
  final cache = ref.read(employeeGalleryPhotoCacheProvider);
  removePhotoMemoryCache(cache, cacheKey: galleryPhotoCacheKey(photoId));
}
