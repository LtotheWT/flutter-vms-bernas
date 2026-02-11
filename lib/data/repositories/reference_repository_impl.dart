import '../../domain/entities/ref_entity_entity.dart';
import '../../domain/repositories/reference_repository.dart';
import '../datasources/reference_remote_data_source.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._remoteDataSource);

  final ReferenceRemoteDataSource _remoteDataSource;

  @override
  Future<List<RefEntityEntity>> getEntities({
    required String accessToken,
  }) async {
    final items = await _remoteDataSource.getEntities(accessToken: accessToken);
    return items.map((item) => item.toEntity()).toList(growable: false);
  }
}
