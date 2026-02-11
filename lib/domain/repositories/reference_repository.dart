import '../entities/ref_entity_entity.dart';
import '../entities/ref_department_entity.dart';

abstract class ReferenceRepository {
  Future<List<RefEntityEntity>> getEntities();

  Future<List<RefDepartmentEntity>> getDepartments({required String entity});
}
