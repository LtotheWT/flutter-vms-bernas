import '../entities/visitor_check_in_result_entity.dart';
import '../entities/visitor_check_in_submission_entity.dart';
import '../repositories/visitor_access_repository.dart';

class SubmitVisitorCheckInUseCase {
  const SubmitVisitorCheckInUseCase(this._repository);

  final VisitorAccessRepository _repository;

  Future<VisitorCheckInResultEntity> call({
    required VisitorCheckInSubmissionEntity submission,
  }) {
    return _repository.submitVisitorCheckIn(submission: submission);
  }
}
