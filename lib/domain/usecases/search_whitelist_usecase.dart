import '../entities/whitelist_search_filter_entity.dart';
import '../entities/whitelist_search_item_entity.dart';
import '../repositories/whitelist_repository.dart';

class SearchWhitelistUseCase {
  const SearchWhitelistUseCase(this._repository);

  final WhitelistRepository _repository;

  Future<List<WhitelistSearchItemEntity>> call({
    required WhitelistSearchFilterEntity filter,
  }) {
    return _repository.searchWhitelist(filter: filter);
  }
}
