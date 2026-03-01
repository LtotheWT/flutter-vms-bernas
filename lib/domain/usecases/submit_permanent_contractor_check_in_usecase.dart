import '../entities/permanent_contractor_submit_entity.dart';
import '../entities/permanent_contractor_submit_result_entity.dart';
import '../repositories/reference_repository.dart';

class SubmitPermanentContractorCheckInUseCase {
  const SubmitPermanentContractorCheckInUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<PermanentContractorSubmitResultEntity> call({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) {
    return _repository.submitPermanentContractorCheckIn(
      submission: submission,
      idempotencyKey: idempotencyKey,
    );
  }
}
