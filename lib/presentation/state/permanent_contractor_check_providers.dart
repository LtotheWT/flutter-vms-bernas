import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/permanent_contractor_info_entity.dart';
import '../../domain/entities/permanent_contractor_submit_entity.dart';
import '../../domain/entities/permanent_contractor_submit_result_entity.dart';
import '../../domain/usecases/get_permanent_contractor_info_usecase.dart';
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

@immutable
class PermanentContractorCheckState {
  const PermanentContractorCheckState({
    this.checkType = PermanentContractorCheckType.checkIn,
    this.searchInput = '',
    this.isLoading = false,
    this.isSubmitting = false,
    this.idempotencyKey,
    this.errorMessage,
    this.info,
  });

  final PermanentContractorCheckType checkType;
  final String searchInput;
  final bool isLoading;
  final bool isSubmitting;
  final String? idempotencyKey;
  final String? errorMessage;
  final PermanentContractorInfoEntity? info;

  PermanentContractorCheckState copyWith({
    PermanentContractorCheckType? checkType,
    String? searchInput,
    bool? isLoading,
    bool? isSubmitting,
    Object? idempotencyKey = _unset,
    Object? errorMessage = _unset,
    Object? info = _unset,
  }) {
    return PermanentContractorCheckState(
      checkType: checkType ?? this.checkType,
      searchInput: searchInput ?? this.searchInput,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      idempotencyKey: identical(idempotencyKey, _unset)
          ? this.idempotencyKey
          : idempotencyKey as String?,
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
      const PermanentContractorCheckState();

  void setCheckType(PermanentContractorCheckType value) {
    if (state.checkType == value) {
      return;
    }
    state = state.copyWith(checkType: value, idempotencyKey: null);
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

    final idempotencyKey = state.idempotencyKey ?? _uuid.v4();
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      idempotencyKey: idempotencyKey,
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
