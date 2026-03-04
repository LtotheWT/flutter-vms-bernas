import '../../domain/entities/whitelist_search_filter_entity.dart';
import '../../domain/entities/whitelist_search_item_entity.dart';
import '../../domain/repositories/whitelist_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/whitelist_remote_data_source.dart';
import '../models/whitelist_search_request_dto.dart';

class WhitelistRepositoryImpl implements WhitelistRepository {
  WhitelistRepositoryImpl(this._remoteDataSource, this._authLocalDataSource);

  final WhitelistRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to load whitelist data.');
    }

    final requestDto = WhitelistSearchRequestDto.fromEntity(filter);
    final dtos = await _remoteDataSource.searchWhitelist(
      accessToken: accessToken,
      request: requestDto,
    );
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }
}
