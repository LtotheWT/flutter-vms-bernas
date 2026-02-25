import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/visitor_access_remote_data_source.dart';
import '../../data/repositories/visitor_access_repository_impl.dart';
import '../../domain/entities/visitor_lookup_entity.dart';
import '../../domain/repositories/visitor_access_repository.dart';
import '../../domain/usecases/get_visitor_lookup_usecase.dart';
import 'auth_session_providers.dart';

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

@immutable
class VisitorCheckState {
  const VisitorCheckState({
    this.searchInput = '',
    this.isLoading = false,
    this.errorMessage,
    this.lookup,
  });

  final String searchInput;
  final bool isLoading;
  final String? errorMessage;
  final VisitorLookupEntity? lookup;

  VisitorCheckState copyWith({
    String? searchInput,
    bool? isLoading,
    Object? errorMessage = _unset,
    Object? lookup = _unset,
  }) {
    return VisitorCheckState(
      searchInput: searchInput ?? this.searchInput,
      isLoading: isLoading ?? this.isLoading,
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
    if (state.isLoading) {
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
}
