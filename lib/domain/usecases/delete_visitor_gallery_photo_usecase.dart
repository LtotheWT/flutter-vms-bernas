import '../entities/visitor_delete_photo_result_entity.dart';
import '../repositories/visitor_access_repository.dart';

class DeleteVisitorGalleryPhotoUseCase {
  const DeleteVisitorGalleryPhotoUseCase(this._repository);

  final VisitorAccessRepository _repository;

  Future<VisitorDeletePhotoResultEntity> call({required int photoId}) {
    return _repository.deleteVisitorGalleryPhoto(photoId: photoId);
  }
}
