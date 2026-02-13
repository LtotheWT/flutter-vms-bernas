import '../../domain/entities/ref_department_entity.dart';
import '../../domain/entities/ref_entity_entity.dart';
import '../../domain/entities/ref_location_entity.dart';
import '../../domain/repositories/reference_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/reference_remote_data_source.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._remoteDataSource, this._authLocalDataSource);

  final ReferenceRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<List<RefEntityEntity>> getEntities() async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load entities.',
    );
    final items = await _remoteDataSource.getEntities(accessToken: accessToken);
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<RefDepartmentEntity>> getDepartments({
    required String entity,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load departments.',
    );
    final items = await _remoteDataSource.getDepartments(
      accessToken: accessToken,
      entity: entity,
    );
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<RefLocationEntity>> getLocations({required String entity}) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load locations.',
    );
    final items = await _remoteDataSource.getLocations(
      accessToken: accessToken,
      entity: entity,
    );
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  Future<String> _getAccessTokenOrThrow({
    required String missingMessage,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception(missingMessage);
    }
    return accessToken;
  }
}
