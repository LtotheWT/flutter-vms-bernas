import '../entities/employee_delete_photo_result_entity.dart';
import '../repositories/employee_access_repository.dart';

class DeleteEmployeeGalleryPhotoUseCase {
  const DeleteEmployeeGalleryPhotoUseCase(this._repository);

  final EmployeeAccessRepository _repository;

  Future<EmployeeDeletePhotoResultEntity> call({required int photoId}) {
    return _repository.deleteEmployeeGalleryPhoto(photoId: photoId);
  }
}
