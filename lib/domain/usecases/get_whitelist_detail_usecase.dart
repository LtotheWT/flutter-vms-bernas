import '../entities/whitelist_detail_entity.dart';
import '../repositories/whitelist_repository.dart';

class GetWhitelistDetailUseCase {
  const GetWhitelistDetailUseCase(this._repository);

  final WhitelistRepository _repository;

  Future<WhitelistDetailEntity> call({
    required String entity,
    required String vehiclePlate,
  }) {
    return _repository.getWhitelistDetail(
      entity: entity,
      vehiclePlate: vehiclePlate,
    );
  }
}
