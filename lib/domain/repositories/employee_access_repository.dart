import '../entities/employee_info_entity.dart';
import '../entities/employee_submit_entity.dart';
import '../entities/employee_submit_result_entity.dart';
import 'dart:typed_data';

abstract class EmployeeAccessRepository {
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code});

  Future<Uint8List?> getEmployeeImage({required String employeeId});

  Future<EmployeeSubmitResultEntity> submitEmployeeCheckIn({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  });

  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  });
}
