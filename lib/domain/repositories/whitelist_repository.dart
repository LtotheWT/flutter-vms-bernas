import '../entities/whitelist_search_filter_entity.dart';
import '../entities/whitelist_detail_entity.dart';
import '../entities/whitelist_search_item_entity.dart';

abstract class WhitelistRepository {
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  });

  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  });
}
