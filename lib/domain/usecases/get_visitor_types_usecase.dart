import '../entities/ref_visitor_type_entity.dart';
import '../repositories/reference_repository.dart';

class GetVisitorTypesUseCase {
  const GetVisitorTypesUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<List<RefVisitorTypeEntity>> call() {
    return _repository.getVisitorTypes();
  }
}
