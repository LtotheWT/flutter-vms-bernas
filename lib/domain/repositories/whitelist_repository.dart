import '../entities/whitelist_search_filter_entity.dart';
import '../entities/whitelist_detail_entity.dart';
import '../entities/whitelist_search_item_entity.dart';
import '../entities/whitelist_submit_entity.dart';
import '../entities/whitelist_submit_result_entity.dart';

abstract class WhitelistRepository {
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  });

  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  });

  Future<WhitelistSubmitResultEntity> submitWhitelistCheckIn({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  });

  Future<WhitelistSubmitResultEntity> submitWhitelistCheckOut({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  });
}
