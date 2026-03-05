import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/whitelist_detail_entity.dart';
import '../../domain/entities/whitelist_submit_entity.dart';
import '../../domain/entities/whitelist_submit_result_entity.dart';
import '../../domain/usecases/get_whitelist_detail_usecase.dart';
import '../../domain/usecases/submit_whitelist_check_in_usecase.dart';
import '../../domain/usecases/submit_whitelist_check_out_usecase.dart';
import 'auth_session_providers.dart';
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

@immutable
class WhitelistDetailState {
  const WhitelistDetailState({
    this.detail,
    this.isLoading = false,
    this.isSubmitting = false,
    this.idempotencyKey,
    this.idempotencySignature,
    this.errorMessage,
    this.hasLoaded = false,
    this.checkType = 'I',
  });

  final WhitelistDetailEntity? detail;
  final bool isLoading;
  final bool isSubmitting;
  final String? idempotencyKey;
  final String? idempotencySignature;
  final String? errorMessage;
  final bool hasLoaded;
  final String checkType;

  WhitelistDetailState copyWith({
    Object? detail = _unset,
    bool? isLoading,
    bool? isSubmitting,
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
    if (normalizedEntity.isEmpty || normalizedVehiclePlate.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: 'Missing whitelist detail identifiers.',
        checkType: normalizedCheckType,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      checkType: normalizedCheckType,
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
}
