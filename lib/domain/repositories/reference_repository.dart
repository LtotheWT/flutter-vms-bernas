import '../entities/ref_entity_entity.dart';

abstract class ReferenceRepository {
  Future<List<RefEntityEntity>> getEntities({required String accessToken});
}
