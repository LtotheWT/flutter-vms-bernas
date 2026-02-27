import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/permanent_contractor_info_entity.dart';
import '../../domain/usecases/get_permanent_contractor_info_usecase.dart';
import 'reference_providers.dart';
import 'photo_cache_helpers.dart';

enum PermanentContractorCheckType { checkIn, checkOut }

final getPermanentContractorInfoUseCaseProvider =
    Provider<GetPermanentContractorInfoUseCase>((ref) {
      final repository = ref.read(referenceRepositoryProvider);
      return GetPermanentContractorInfoUseCase(repository);
    });

@immutable
class PermanentContractorCheckState {
  const PermanentContractorCheckState({
    this.checkType = PermanentContractorCheckType.checkIn,
    this.searchInput = '',
    this.isLoading = false,
    this.errorMessage,
    this.info,
  });

  final PermanentContractorCheckType checkType;
  final String searchInput;
  final bool isLoading;
  final String? errorMessage;
  final PermanentContractorInfoEntity? info;

  PermanentContractorCheckState copyWith({
    PermanentContractorCheckType? checkType,
    String? searchInput,
    bool? isLoading,
    Object? errorMessage = _unset,
    Object? info = _unset,
  }) {
    return PermanentContractorCheckState(
      checkType: checkType ?? this.checkType,
      searchInput: searchInput ?? this.searchInput,
      isLoading: isLoading ?? this.isLoading,
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
  @override
  PermanentContractorCheckState build() =>
      const PermanentContractorCheckState();

  void setCheckType(PermanentContractorCheckType value) {
    if (state.checkType == value) {
      return;
    }
    state = state.copyWith(checkType: value);
  }

  void updateSearchInput(String value) {
    if (state.searchInput == value) {
      return;
    }
    state = state.copyWith(searchInput: value, errorMessage: null);
  }

  void clearResult() {
    state = state.copyWith(info: null, errorMessage: null);
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
      final info = await useCase(code: state.searchInput);
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        info: info,
        searchInput: '',
      );
      return true;
    } catch (error) {
      final text = error.toString().trim();
      state = state.copyWith(
        isLoading: false,
        errorMessage: text.startsWith('Exception:')
            ? text.replaceFirst('Exception:', '').trim()
            : (text.isEmpty
                  ? 'Failed to load permanent contractor info.'
                  : text),
      );
      return false;
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
