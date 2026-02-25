import '../entities/visitor_lookup_entity.dart';
import '../repositories/visitor_access_repository.dart';

class GetVisitorLookupUseCase {
  const GetVisitorLookupUseCase(this._repository);

  final VisitorAccessRepository _repository;

  Future<VisitorLookupEntity> call({
    required String code,
    required bool isCheckIn,
  }) {
    return _repository.getVisitorLookup(code: code, isCheckIn: isCheckIn);
  }
}
