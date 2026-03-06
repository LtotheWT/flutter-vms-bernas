import 'dart:typed_data';

import '../entities/whitelist_delete_photo_result_entity.dart';
import '../entities/whitelist_search_filter_entity.dart';
import '../entities/whitelist_detail_entity.dart';
import '../entities/whitelist_gallery_item_entity.dart';
import '../entities/whitelist_search_item_entity.dart';
import '../entities/whitelist_save_photo_result_entity.dart';
import '../entities/whitelist_save_photo_submission_entity.dart';
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

  Future<List<WhitelistGalleryItemEntity>> getWhitelistGalleryList({
    required String guid,
  });

  Future<Uint8List?> getWhitelistPhoto({required int photoId});

  Future<WhitelistSavePhotoResultEntity> saveWhitelistPhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  });

  Future<WhitelistDeletePhotoResultEntity> deleteWhitelistPhoto({
    required int photoId,
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
