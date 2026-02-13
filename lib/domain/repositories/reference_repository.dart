import '../entities/ref_entity_entity.dart';
import '../entities/ref_department_entity.dart';
import '../entities/ref_location_entity.dart';
import '../entities/ref_personel_entity.dart';
import '../entities/ref_visitor_type_entity.dart';

abstract class ReferenceRepository {
  Future<List<RefEntityEntity>> getEntities();

  Future<List<RefDepartmentEntity>> getDepartments({required String entity});

  Future<List<RefLocationEntity>> getLocations({required String entity});

  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  });

  Future<List<RefVisitorTypeEntity>> getVisitorTypes();
}
