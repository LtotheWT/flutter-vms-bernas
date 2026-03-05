import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/error_messages.dart';
import '../../data/datasources/employee_access_remote_data_source.dart';
import '../../data/repositories/employee_access_repository_impl.dart';
import '../../domain/entities/employee_info_entity.dart';
import '../../domain/entities/employee_submit_entity.dart';
import '../../domain/entities/employee_submit_result_entity.dart';
import '../../domain/repositories/employee_access_repository.dart';
import '../../domain/usecases/get_employee_info_usecase.dart';
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

@immutable
class EmployeeCheckState {
  const EmployeeCheckState({
    this.checkType = EmployeeCheckType.checkIn,
    this.searchInput = '',
    this.info,
    this.isLoading = false,
    this.isSubmitting = false,
    this.idempotencyKey,
    this.idempotencySignature,
    this.errorMessage,
  });

  final EmployeeCheckType checkType;
  final String searchInput;
  final EmployeeInfoEntity? info;
  final bool isLoading;
  final bool isSubmitting;
  final String? idempotencyKey;
  final String? idempotencySignature;
  final String? errorMessage;

  EmployeeCheckState copyWith({
    EmployeeCheckType? checkType,
    String? searchInput,
    Object? info = _unset,
    bool? isLoading,
    bool? isSubmitting,
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
  EmployeeCheckState build() => const EmployeeCheckState();

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
