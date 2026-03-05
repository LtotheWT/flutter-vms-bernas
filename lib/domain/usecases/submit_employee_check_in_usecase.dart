import '../entities/employee_submit_entity.dart';
import '../entities/employee_submit_result_entity.dart';
import '../repositories/employee_access_repository.dart';

class SubmitEmployeeCheckInUseCase {
  const SubmitEmployeeCheckInUseCase(this._repository);

  final EmployeeAccessRepository _repository;

  Future<EmployeeSubmitResultEntity> call({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) {
    return _repository.submitEmployeeCheckIn(
      submission: submission,
      idempotencyKey: idempotencyKey,
    );
  }
}
