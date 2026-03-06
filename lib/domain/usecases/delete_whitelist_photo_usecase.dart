import '../entities/whitelist_delete_photo_result_entity.dart';
import '../repositories/whitelist_repository.dart';

class DeleteWhitelistPhotoUseCase {
  const DeleteWhitelistPhotoUseCase(this._repository);

  final WhitelistRepository _repository;

  Future<WhitelistDeletePhotoResultEntity> call({required int photoId}) {
    return _repository.deleteWhitelistPhoto(photoId: photoId);
  }
}
