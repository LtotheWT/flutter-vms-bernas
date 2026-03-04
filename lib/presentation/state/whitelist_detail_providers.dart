import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/whitelist_detail_entity.dart';
import '../../domain/usecases/get_whitelist_detail_usecase.dart';
import 'whitelist_check_providers.dart';

final getWhitelistDetailUseCaseProvider = Provider<GetWhitelistDetailUseCase>((
  ref,
) {
  final repository = ref.read(whitelistRepositoryProvider);
  return GetWhitelistDetailUseCase(repository);
});

@immutable
class WhitelistDetailState {
  const WhitelistDetailState({
    this.detail,
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
    this.checkType = 'I',
  });

  final WhitelistDetailEntity? detail;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;
  final String checkType;

  WhitelistDetailState copyWith({
    Object? detail = _unset,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? hasLoaded,
    String? checkType,
  }) {
    return WhitelistDetailState(
      detail: identical(detail, _unset)
          ? this.detail
          : detail as WhitelistDetailEntity?,
      isLoading: isLoading ?? this.isLoading,
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
      );
    } catch (error) {
      final text = error.toString().trim();
      state = state.copyWith(
        isLoading: false,
        errorMessage: text.startsWith('Exception:')
            ? text.replaceFirst('Exception:', '').trim()
            : (text.isEmpty ? 'Failed to load whitelist detail.' : text),
        hasLoaded: true,
        checkType: normalizedCheckType,
      );
    }
  }
}
