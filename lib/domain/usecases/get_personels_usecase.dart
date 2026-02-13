import '../entities/ref_personel_entity.dart';
import '../repositories/reference_repository.dart';

class GetPersonelsUseCase {
  const GetPersonelsUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<List<RefPersonelEntity>> call({
    required String entity,
    required String site,
    required String department,
  }) {
    return _repository.getPersonels(
      entity: entity,
      site: site,
      department: department,
    );
  }
}
