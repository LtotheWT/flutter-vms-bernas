import '../entities/whitelist_save_photo_result_entity.dart';
import '../entities/whitelist_save_photo_submission_entity.dart';
import '../repositories/whitelist_repository.dart';

class SaveWhitelistPhotoUseCase {
  const SaveWhitelistPhotoUseCase(this._repository);

  final WhitelistRepository _repository;

  Future<WhitelistSavePhotoResultEntity> call({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) {
    return _repository.saveWhitelistPhoto(submission: submission);
  }
}
