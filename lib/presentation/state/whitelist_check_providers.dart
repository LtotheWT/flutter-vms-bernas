import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/whitelist_remote_data_source.dart';
import '../../data/repositories/whitelist_repository_impl.dart';
import '../../domain/entities/whitelist_search_filter_entity.dart';
import '../../domain/entities/whitelist_search_item_entity.dart';
import '../../domain/repositories/whitelist_repository.dart';
import '../../domain/usecases/search_whitelist_usecase.dart';
import 'auth_session_providers.dart';

final whitelistRemoteDataSourceProvider = Provider<WhitelistRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioClientProvider);
  return WhitelistRemoteDataSource(dio);
});

final whitelistRepositoryProvider = Provider<WhitelistRepository>((ref) {
  final remoteDataSource = ref.read(whitelistRemoteDataSourceProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return WhitelistRepositoryImpl(remoteDataSource, localDataSource);
});

final searchWhitelistUseCaseProvider = Provider<SearchWhitelistUseCase>((ref) {
  final repository = ref.read(whitelistRepositoryProvider);
  return SearchWhitelistUseCase(repository);
});

@immutable
class WhitelistCheckState {
  const WhitelistCheckState({
    this.items = const <WhitelistSearchItemEntity>[],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
    this.activeFilter,
  });

  final List<WhitelistSearchItemEntity> items;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;
  final WhitelistSearchFilterEntity? activeFilter;

  WhitelistCheckState copyWith({
    List<WhitelistSearchItemEntity>? items,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? hasLoaded,
    Object? activeFilter = _unset,
  }) {
    return WhitelistCheckState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      activeFilter: identical(activeFilter, _unset)
          ? this.activeFilter
          : activeFilter as WhitelistSearchFilterEntity?,
    );
  }
}

const Object _unset = Object();

final whitelistCheckControllerProvider =
    NotifierProvider.autoDispose<WhitelistCheckController, WhitelistCheckState>(
      WhitelistCheckController.new,
    );

class WhitelistCheckController extends Notifier<WhitelistCheckState> {
  @override
  WhitelistCheckState build() => const WhitelistCheckState();

  Future<void> loadInitial({
    required String currentType,
    required String defaultEntity,
  }) {
    final entity = defaultEntity.trim();
    final type = currentType.trim().toUpperCase();
    if (entity.isEmpty || (type != 'I' && type != 'O')) {
      state = state.copyWith(
        hasLoaded: true,
        items: const <WhitelistSearchItemEntity>[],
        errorMessage: 'Entity is required to load whitelist records.',
      );
      return Future<void>.value();
    }

    return _fetch(
      filter: WhitelistSearchFilterEntity(entity: entity, currentType: type),
    );
  }

  Future<void> applyFilters(WhitelistSearchFilterEntity filter) {
    return _fetch(filter: filter);
  }

  Future<void> _fetch({required WhitelistSearchFilterEntity filter}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final useCase = ref.read(searchWhitelistUseCaseProvider);
      final items = await useCase(filter: filter);
      state = state.copyWith(
        items: items,
        isLoading: false,
        errorMessage: null,
        hasLoaded: true,
        activeFilter: filter,
      );
    } catch (error) {
      final text = error.toString().trim();
      state = state.copyWith(
        isLoading: false,
        errorMessage: text.startsWith('Exception:')
            ? text.replaceFirst('Exception:', '').trim()
            : (text.isEmpty ? 'Failed to load whitelist records.' : text),
        hasLoaded: true,
        activeFilter: filter,
      );
    }
  }
}
