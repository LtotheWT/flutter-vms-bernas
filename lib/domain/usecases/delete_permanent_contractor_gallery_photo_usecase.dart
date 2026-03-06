import '../entities/permanent_contractor_delete_photo_result_entity.dart';
import '../repositories/reference_repository.dart';

class DeletePermanentContractorGalleryPhotoUseCase {
  const DeletePermanentContractorGalleryPhotoUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<PermanentContractorDeletePhotoResultEntity> call({
    required int photoId,
  }) {
    return _repository.deletePermanentContractorGalleryPhoto(photoId: photoId);
  }
}
