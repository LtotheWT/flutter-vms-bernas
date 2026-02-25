import '../../domain/entities/visitor_lookup_entity.dart';
import '../../domain/repositories/visitor_access_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/visitor_access_remote_data_source.dart';

class VisitorAccessRepositoryImpl implements VisitorAccessRepository {
  VisitorAccessRepositoryImpl(
    this._remoteDataSource,
    this._authLocalDataSource,
  );

  final VisitorAccessRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to load visitor data.');
    }

    final details = await _remoteDataSource.getVisitorLookup(
      accessToken: accessToken,
      code: code,
      isCheckIn: isCheckIn,
    );
    return details.toEntity();
  }
}
