import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/domain/entities/employee_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/employee_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/employee_info_entity.dart';
import 'package:vms_bernas/domain/entities/employee_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/employee_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/employee_access_repository.dart';
import 'package:vms_bernas/domain/usecases/delete_employee_gallery_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/get_employee_info_usecase.dart';
import 'package:vms_bernas/domain/usecases/save_employee_photo_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_employee_check_in_usecase.dart';
import 'package:vms_bernas/domain/usecases/submit_employee_check_out_usecase.dart';
import 'package:vms_bernas/presentation/state/auth_session_providers.dart';
import 'package:vms_bernas/presentation/state/employee_check_providers.dart';

class _FakeEmployeeAccessRepository implements EmployeeAccessRepository {
  _FakeEmployeeAccessRepository({
    this.lookupShouldThrow = false,
    this.submitShouldThrow = false,
    this.submitDelay = Duration.zero,
  });

  final bool lookupShouldThrow;
  final bool submitShouldThrow;
  final Duration submitDelay;
  String? lastLookupCode;
  final List<String> checkInIdempotencyKeys = <String>[];
  final List<String> checkOutIdempotencyKeys = <String>[];
  EmployeeSubmitEntity? lastCheckInSubmission;
  EmployeeSubmitEntity? lastCheckOutSubmission;
  EmployeeSavePhotoSubmissionEntity? lastSavePhotoSubmission;
  int? lastDeletedPhotoId;

  @override
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code}) async {
    lastLookupCode = code;
    if (lookupShouldThrow) {
      throw Exception('lookup failed');
    }
    return const EmployeeInfoEntity(
      employeeId: 'EMP0001',
      employeeName: 'Suraya',
      site: 'FACTORY1',
      department: 'ADC',
      unit: 'ABC',
      vehicleType: 'CAR',
      handphoneNo: '2',
      telNoExtension: '3',
      effectiveWorkingDate: '2025-11-01T00:00:00',
      lastWorkingDate: '2025-11-30T00:00:00',
    );
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckIn({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    if (submitDelay > Duration.zero) {
      await Future<void>.delayed(submitDelay);
    }
    lastCheckInSubmission = submission;
    checkInIdempotencyKeys.add(idempotencyKey);
    if (submitShouldThrow) {
      throw Exception('submit failed');
    }
    return const EmployeeSubmitResultEntity(status: true, message: 'ok');
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    if (submitDelay > Duration.zero) {
      await Future<void>.delayed(submitDelay);
    }
    lastCheckOutSubmission = submission;
    checkOutIdempotencyKeys.add(idempotencyKey);
    if (submitShouldThrow) {
      throw Exception('submit failed');
    }
    return const EmployeeSubmitResultEntity(status: true, message: 'ok');
  }

  @override
  Future<Uint8List?> getEmployeeImage({required String employeeId}) async {
    return null;
  }

  @override
  Future<List<EmployeeGalleryItemEntity>> getEmployeeGalleryList({
    required String guid,
  }) async {
    return const <EmployeeGalleryItemEntity>[];
  }

  @override
  Future<Uint8List?> getEmployeeGalleryPhoto({required int photoId}) async {
    return Uint8List.fromList(const [7, 8, 9]);
  }

  @override
  Future<EmployeeSavePhotoResultEntity> saveEmployeePhoto({
    required EmployeeSavePhotoSubmissionEntity submission,
  }) async {
    lastSavePhotoSubmission = submission;
    if (submitShouldThrow) {
      throw Exception('photo submit failed');
    }
    return const EmployeeSavePhotoResultEntity(
      success: true,
      message: 'Photo saved successfully',
      photoId: 40,
    );
  }

  @override
  Future<EmployeeDeletePhotoResultEntity> deleteEmployeeGalleryPhoto({
    required int photoId,
  }) async {
    lastDeletedPhotoId = photoId;
    if (submitShouldThrow) {
      throw Exception('photo delete failed');
    }
    return const EmployeeDeletePhotoResultEntity(
      success: true,
      message: 'delete is successful',
    );
  }
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource(this._session) : super(const FlutterSecureStorage());

  final AuthSessionDto? _session;

  @override
  Future<AuthSessionDto?> getSession() async => _session;
}

ProviderContainer _createContainer(_FakeEmployeeAccessRepository repository) {
  return ProviderContainer(
    overrides: [
      authLocalDataSourceProvider.overrideWithValue(
        _FakeAuthLocalDataSource(
          const AuthSessionDto(
            username: 'Ryan',
            fullname: 'Ryan',
            entity: 'AGYTEK',
            accessToken: 'token',
            defaultSite: 'FACTORY1',
            defaultGate: 'F1_A',
          ),
        ),
      ),
      getEmployeeInfoUseCaseProvider.overrideWithValue(
        GetEmployeeInfoUseCase(repository),
      ),
      submitEmployeeCheckInUseCaseProvider.overrideWithValue(
        SubmitEmployeeCheckInUseCase(repository),
      ),
      submitEmployeeCheckOutUseCaseProvider.overrideWithValue(
        SubmitEmployeeCheckOutUseCase(repository),
      ),
      saveEmployeePhotoUseCaseProvider.overrideWithValue(
        SaveEmployeePhotoUseCase(repository),
      ),
      deleteEmployeeGalleryPhotoUseCaseProvider.overrideWithValue(
        DeleteEmployeeGalleryPhotoUseCase(repository),
      ),
    ],
  );
}

void main() {
  test('search success clears input and sets info', () async {
    final repository = _FakeEmployeeAccessRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(employeeCheckControllerProvider.notifier);
    controller.updateSearchInput('EMP|EMP0001||');
    final ok = await controller.search();
    final state = container.read(employeeCheckControllerProvider);

    expect(ok, isTrue);
    expect(repository.lastLookupCode, 'EMP|EMP0001||');
    expect(state.searchInput, '');
    expect(state.info?.employeeId, 'EMP0001');
    expect(state.errorMessage, isNull);
  });

  test('search failure keeps input and sets error', () async {
    final repository = _FakeEmployeeAccessRepository(lookupShouldThrow: true);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(employeeCheckControllerProvider.notifier);
    controller.updateSearchInput('EMP|BAD||');
    final ok = await controller.search();
    final state = container.read(employeeCheckControllerProvider);

    expect(ok, isFalse);
    expect(state.searchInput, 'EMP|BAD||');
    expect(state.info, isNull);
    expect(state.errorMessage, 'lookup failed');
  });

  test('submit check-in succeeds and reuses idempotency on retry', () async {
    final repository = _FakeEmployeeAccessRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(employeeCheckControllerProvider.notifier);
    controller.updateSearchInput('EMP|EMP0001||');
    await controller.search();
    final first = await controller.submit();
    final second = await controller.submit();

    expect(first.status, isTrue);
    expect(second.status, isTrue);
    expect(repository.checkInIdempotencyKeys, hasLength(2));
    expect(
      repository.checkInIdempotencyKeys[0],
      repository.checkInIdempotencyKeys[1],
    );
    expect(repository.lastCheckInSubmission?.employeeId, 'EMP0001');
    expect(repository.lastCheckInSubmission?.site, 'FACTORY1');
    expect(repository.lastCheckInSubmission?.gate, 'F1_A');
    expect(repository.lastCheckInSubmission?.createdBy, 'Ryan');
  });

  test('idempotency key resets when check type changes', () async {
    final repository = _FakeEmployeeAccessRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(employeeCheckControllerProvider.notifier);
    controller.updateSearchInput('EMP|EMP0001||');
    await controller.search();
    await controller.submit();
    final checkInKey = repository.checkInIdempotencyKeys.last;

    controller.setCheckType(EmployeeCheckType.checkOut);
    await controller.submit();
    final checkOutKey = repository.checkOutIdempotencyKeys.last;

    expect(checkInKey, isNot(checkOutKey));
  });

  test('submit guard prevents duplicate in-flight request', () async {
    final repository = _FakeEmployeeAccessRepository(
      submitDelay: const Duration(milliseconds: 150),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    final sub = container.listen(
      employeeCheckControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final controller = container.read(employeeCheckControllerProvider.notifier);
    controller.updateSearchInput('EMP|EMP0001||');
    await controller.search();

    final firstFuture = controller.submit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final second = await controller.submit();
    final first = await firstFuture;

    expect(first.status, isTrue);
    expect(second.status, isFalse);
    expect(second.message, 'Submission is currently in progress.');
  });

  test('submit failure returns normalized error and clears state', () async {
    final repository = _FakeEmployeeAccessRepository(submitShouldThrow: true);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final controller = container.read(employeeCheckControllerProvider.notifier);
    controller.updateSearchInput('EMP|EMP0001||');
    await controller.search();
    final result = await controller.submit();

    expect(result.status, isFalse);
    expect(result.message, 'submit failed');
    final state = container.read(employeeCheckControllerProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.errorMessage, 'submit failed');
  });

  test('build creates one photo session guid and keeps it stable', () async {
    final repository = _FakeEmployeeAccessRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final firstGuid = container
        .read(employeeCheckControllerProvider)
        .photoSessionGuid;
    final controller = container.read(employeeCheckControllerProvider.notifier);

    controller.setCheckType(EmployeeCheckType.checkOut);
    final secondGuid = container
        .read(employeeCheckControllerProvider)
        .photoSessionGuid;

    expect(firstGuid, isNotEmpty);
    expect(secondGuid, firstGuid);
  });

  test('save photo forwards submission and clears uploading state', () async {
    final repository = _FakeEmployeeAccessRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final result = await container
        .read(employeeCheckControllerProvider.notifier)
        .savePhoto(
          submission: const EmployeeSavePhotoSubmissionEntity(
            imageBase64: 'abc',
            photoDescription: 'Gate',
            guid: 'guid-1',
            entity: 'AGYTEK',
            site: 'FACTORY1',
            uploadedBy: 'Ryan',
          ),
        );

    expect(result.success, isTrue);
    expect(repository.lastSavePhotoSubmission?.guid, 'guid-1');
    expect(
      container.read(employeeCheckControllerProvider).isUploadingPhoto,
      isFalse,
    );
  });

  test('delete photo forwards photo id and clears deleting state', () async {
    final repository = _FakeEmployeeAccessRepository();
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final result = await container
        .read(employeeCheckControllerProvider.notifier)
        .deletePhoto(photoId: 40);

    expect(result.success, isTrue);
    expect(repository.lastDeletedPhotoId, 40);
    final state = container.read(employeeCheckControllerProvider);
    expect(state.isDeletingPhoto, isFalse);
    expect(state.deletingPhotoId, isNull);
  });
}
