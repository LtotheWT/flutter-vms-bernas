import '../entities/employee_save_photo_result_entity.dart';
import '../entities/employee_save_photo_submission_entity.dart';
import '../repositories/employee_access_repository.dart';

class SaveEmployeePhotoUseCase {
  const SaveEmployeePhotoUseCase(this._repository);

  final EmployeeAccessRepository _repository;

  Future<EmployeeSavePhotoResultEntity> call({
    required EmployeeSavePhotoSubmissionEntity submission,
  }) {
    return _repository.saveEmployeePhoto(submission: submission);
  }
}
