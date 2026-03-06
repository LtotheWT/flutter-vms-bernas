import '../entities/permanent_contractor_save_photo_result_entity.dart';
import '../entities/permanent_contractor_save_photo_submission_entity.dart';
import '../repositories/reference_repository.dart';

class SavePermanentContractorPhotoUseCase {
  const SavePermanentContractorPhotoUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<PermanentContractorSavePhotoResultEntity> call({
    required PermanentContractorSavePhotoSubmissionEntity submission,
  }) {
    return _repository.savePermanentContractorPhoto(submission: submission);
  }
}
