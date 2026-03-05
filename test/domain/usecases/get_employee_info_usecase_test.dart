import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/employee_info_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/employee_access_repository.dart';
import 'package:vms_bernas/domain/usecases/get_employee_info_usecase.dart';

class _FakeEmployeeAccessRepository implements EmployeeAccessRepository {
  String? capturedCode;

  @override
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code}) async {
    capturedCode = code;
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getEmployeeImage({required String employeeId}) {
    throw UnimplementedError();
  }
}

void main() {
  test('forwards code to repository', () async {
    final repository = _FakeEmployeeAccessRepository();
    final useCase = GetEmployeeInfoUseCase(repository);

    await useCase(code: 'EMP|EMP0001||');

    expect(repository.capturedCode, 'EMP|EMP0001||');
  });
}
