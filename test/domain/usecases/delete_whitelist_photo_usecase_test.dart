import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/delete_whitelist_photo_usecase.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  int? capturedPhotoId;

  @override
  Future<WhitelistDeletePhotoResultEntity> deleteWhitelistPhoto({
    required int photoId,
  }) async {
    capturedPhotoId = photoId;
    return const WhitelistDeletePhotoResultEntity(
      success: true,
      message: 'delete is successful',
    );
  }

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) => throw UnimplementedError();

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) => throw UnimplementedError();

  @override
  Future<List<WhitelistGalleryItemEntity>> getWhitelistGalleryList({
    required String guid,
  }) => throw UnimplementedError();

  @override
  Future<Uint8List?> getWhitelistPhoto({required int photoId}) =>
      throw UnimplementedError();

  @override
  Future<WhitelistSavePhotoResultEntity> saveWhitelistPhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) => throw UnimplementedError();

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckIn({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckOut({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) => throw UnimplementedError();
}

void main() {
  test('forwards whitelist photo delete to repository', () async {
    final repository = _FakeWhitelistRepository();
    final useCase = DeleteWhitelistPhotoUseCase(repository);

    final result = await useCase(photoId: 31);

    expect(repository.capturedPhotoId, 31);
    expect(result.success, isTrue);
  });
}
