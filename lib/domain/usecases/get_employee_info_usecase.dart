import '../entities/employee_info_entity.dart';
import '../repositories/employee_access_repository.dart';

class GetEmployeeInfoUseCase {
  const GetEmployeeInfoUseCase(this._repository);

  final EmployeeAccessRepository _repository;

  Future<EmployeeInfoEntity> call({required String code}) {
    return _repository.getEmployeeInfo(code: code);
  }
}
