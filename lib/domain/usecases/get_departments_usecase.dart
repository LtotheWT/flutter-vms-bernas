import '../entities/ref_department_entity.dart';
import '../repositories/reference_repository.dart';

class GetDepartmentsUseCase {
  const GetDepartmentsUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<List<RefDepartmentEntity>> call({required String entity}) {
    return _repository.getDepartments(entity: entity);
  }
}
