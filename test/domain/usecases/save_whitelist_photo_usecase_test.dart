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
import 'package:vms_bernas/domain/usecases/save_whitelist_photo_usecase.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  WhitelistSavePhotoSubmissionEntity? capturedSubmission;

  @override
  Future<WhitelistSavePhotoResultEntity> saveWhitelistPhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) async {
    capturedSubmission = submission;
    return const WhitelistSavePhotoResultEntity(
      success: true,
      message: 'Photo saved successfully',
      photoId: 31,
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
  Future<WhitelistDeletePhotoResultEntity> deleteWhitelistPhoto({
    required int photoId,
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
  test('forwards whitelist photo submission to repository', () async {
    final repository = _FakeWhitelistRepository();
    final useCase = SaveWhitelistPhotoUseCase(repository);
    const submission = WhitelistSavePhotoSubmissionEntity(
      imageBase64: 'abc',
      photoDescription: 'Gate',
      guid: 'guid-123',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      uploadedBy: 'Ryan',
    );

    final result = await useCase(submission: submission);

    expect(repository.capturedSubmission, submission);
    expect(result.photoId, 31);
  });
}
