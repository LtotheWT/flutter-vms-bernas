import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import 'reference_providers.dart';

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>(
  (ref) {
    final repository = ref.read(referenceRepositoryProvider);
    return GetDashboardSummaryUseCase(repository);
  },
);

@immutable
class ReportDashboardState {
  const ReportDashboardState({
    this.summary,
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
    this.activeEntity,
    this.defaultEntity,
  });

  final DashboardSummaryEntity? summary;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;
  final String? activeEntity;
  final String? defaultEntity;

  ReportDashboardState copyWith({
    Object? summary = _unset,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? hasLoaded,
    Object? activeEntity = _unset,
    Object? defaultEntity = _unset,
  }) {
    return ReportDashboardState(
      summary: identical(summary, _unset)
          ? this.summary
          : summary as DashboardSummaryEntity?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      activeEntity: identical(activeEntity, _unset)
          ? this.activeEntity
          : activeEntity as String?,
      defaultEntity: identical(defaultEntity, _unset)
          ? this.defaultEntity
          : defaultEntity as String?,
    );
  }
}

const Object _unset = Object();

final reportDashboardControllerProvider =
    NotifierProvider.autoDispose<
      ReportDashboardController,
      ReportDashboardState
    >(ReportDashboardController.new);

class ReportDashboardController extends Notifier<ReportDashboardState> {
  @override
  ReportDashboardState build() => const ReportDashboardState();

  Future<void> loadInitial({required String defaultEntity}) async {
    final normalizedDefault = defaultEntity.trim();
    if (normalizedDefault.isEmpty) {
      state = state.copyWith(
        hasLoaded: true,
        isLoading: false,
        summary: null,
        errorMessage: 'Entity is required to load dashboard.',
        activeEntity: null,
        defaultEntity: null,
      );
      return;
    }

    state = state.copyWith(defaultEntity: normalizedDefault);
    await _fetch(normalizedDefault);
  }

  Future<void> applyEntity(String entity) {
    return _fetch(entity.trim());
  }

  Future<void> _fetch(String entity) async {
    final normalizedEntity = entity.trim();
    if (normalizedEntity.isEmpty) {
      state = state.copyWith(
        summary: null,
        hasLoaded: true,
        isLoading: false,
        errorMessage: 'Entity is required to load dashboard.',
        activeEntity: null,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      activeEntity: normalizedEntity,
    );

    try {
      final useCase = ref.read(getDashboardSummaryUseCaseProvider);
      final summary = await useCase(entity: normalizedEntity);
      state = state.copyWith(
        summary: summary,
        isLoading: false,
        errorMessage: null,
        hasLoaded: true,
        activeEntity: normalizedEntity,
      );
    } catch (error) {
      final message = toDisplayErrorMessage(
        error,
        fallback: 'Failed to load dashboard data.',
      );
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: message,
        activeEntity: normalizedEntity,
      );
    }
  }
}
