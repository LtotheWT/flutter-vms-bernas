import '../entities/whitelist_submit_entity.dart';
import '../entities/whitelist_submit_result_entity.dart';
import '../repositories/whitelist_repository.dart';

class SubmitWhitelistCheckInUseCase {
  const SubmitWhitelistCheckInUseCase(this._repository);

  final WhitelistRepository _repository;

  Future<WhitelistSubmitResultEntity> call({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) {
    return _repository.submitWhitelistCheckIn(
      submission: submission,
      idempotencyKey: idempotencyKey,
    );
  }
}
