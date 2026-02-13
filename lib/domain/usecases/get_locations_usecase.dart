import '../entities/ref_location_entity.dart';
import '../repositories/reference_repository.dart';

class GetLocationsUseCase {
  const GetLocationsUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<List<RefLocationEntity>> call({required String entity}) {
    return _repository.getLocations(entity: entity);
  }
}
