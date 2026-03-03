import '../entities/visitor_save_photo_result_entity.dart';
import '../entities/visitor_save_photo_submission_entity.dart';
import '../repositories/visitor_access_repository.dart';

class SaveVisitorPhotoUseCase {
  const SaveVisitorPhotoUseCase(this._repository);

  final VisitorAccessRepository _repository;

  Future<VisitorSavePhotoResultEntity> call({
    required VisitorSavePhotoSubmissionEntity submission,
  }) {
    return _repository.saveVisitorPhoto(submission: submission);
  }
}
