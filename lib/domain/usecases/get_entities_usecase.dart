import '../entities/ref_entity_entity.dart';
import '../repositories/reference_repository.dart';

class GetEntitiesUseCase {
  const GetEntitiesUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<List<RefEntityEntity>> call({required String accessToken}) {
    return _repository.getEntities(accessToken: accessToken);
  }
}
