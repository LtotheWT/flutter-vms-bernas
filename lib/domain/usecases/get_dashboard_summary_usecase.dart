import '../entities/dashboard_summary_entity.dart';
import '../repositories/reference_repository.dart';

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);

  final ReferenceRepository _repository;

  Future<DashboardSummaryEntity> call({required String entity}) {
    return _repository.getDashboardSummary(entity: entity);
  }
}
