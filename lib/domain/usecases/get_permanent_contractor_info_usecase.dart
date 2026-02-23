import '../entities/permanent_contractor_info_entity.dart';
import '../repositories/reference_repository.dart';

class GetPermanentContractorInfoUseCase {
  const GetPermanentContractorInfoUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<PermanentContractorInfoEntity> call({required String code}) {
    return _repository.getPermanentContractorInfo(code: code);
  }
}
