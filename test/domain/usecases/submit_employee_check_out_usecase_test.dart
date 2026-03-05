import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/employee_info_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/employee_access_repository.dart';
import 'package:vms_bernas/domain/usecases/submit_employee_check_out_usecase.dart';

class _FakeEmployeeAccessRepository implements EmployeeAccessRepository {
  EmployeeSubmitEntity? capturedSubmission;
  String? capturedIdempotencyKey;

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    capturedSubmission = submission;
    capturedIdempotencyKey = idempotencyKey;
    return const EmployeeSubmitResultEntity(status: true, message: 'ok');
  }

  @override
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code}) {
    throw UnimplementedError();
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckIn({
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
  test('forwards submit check-out payload', () async {
    final repository = _FakeEmployeeAccessRepository();
    final useCase = SubmitEmployeeCheckOutUseCase(repository);

    const submission = EmployeeSubmitEntity(
      employeeId: 'EMP0001',
      site: 'FACTORY1',
      gate: 'F1_A',
      createdBy: 'Ryan',
    );
    await useCase(submission: submission, idempotencyKey: 'idem-1');

    expect(repository.capturedSubmission, submission);
    expect(repository.capturedIdempotencyKey, 'idem-1');
  });
}
