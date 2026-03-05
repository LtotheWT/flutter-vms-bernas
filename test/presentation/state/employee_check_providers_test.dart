import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:vms_bernas/data/datasources/auth_local_data_source.dart';
import 'package:vms_bernas/data/models/auth_session_dto.dart';
import 'package:vms_bernas/domain/entities/employee_info_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/employee_access_repository.dart';
import 'package:vms_bernas/domain/usecases/get_employee_info_usecase.dart';
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
}
