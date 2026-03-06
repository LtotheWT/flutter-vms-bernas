import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/whitelist_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_detail_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_item_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_entity.dart';
import 'package:vms_bernas/domain/entities/whitelist_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/whitelist_repository.dart';
import 'package:vms_bernas/domain/usecases/submit_whitelist_check_in_usecase.dart';

class _FakeWhitelistRepository implements WhitelistRepository {
  WhitelistSubmitEntity? capturedSubmission;
  String? capturedIdempotencyKey;

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckIn({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    capturedSubmission = submission;
    capturedIdempotencyKey = idempotencyKey;
    return const WhitelistSubmitResultEntity(
      status: true,
      message: 'Whitelist checked IN successfully.',
    );
  }

  @override
  Future<WhitelistSubmitResultEntity> submitWhitelistCheckOut({
    required WhitelistSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WhitelistDetailEntity> getWhitelistDetail({
    required String entity,
    required String vehiclePlate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<WhitelistSearchItemEntity>> searchWhitelist({
    required WhitelistSearchFilterEntity filter,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<WhitelistGalleryItemEntity>> getWhitelistGalleryList({
    required String guid,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getWhitelistPhoto({required int photoId}) {
    throw UnimplementedError();
  }

  @override
  Future<WhitelistSavePhotoResultEntity> saveWhitelistPhoto({
    required WhitelistSavePhotoSubmissionEntity submission,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WhitelistDeletePhotoResultEntity> deleteWhitelistPhoto({
    required int photoId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('forwards submission and idempotency key', () async {
    final repository = _FakeWhitelistRepository();
    final useCase = SubmitWhitelistCheckInUseCase(repository);

    final result = await useCase(
      submission: const WhitelistSubmitEntity(
        entity: 'AGYTEK',
        site: 'FACTORY1',
        gate: 'F1_A',
        vehiclePlate: 'RYAN1234',
        createdBy: 'Ryan',
      ),
      idempotencyKey: 'idem-1',
    );

    expect(repository.capturedIdempotencyKey, 'idem-1');
    expect(repository.capturedSubmission?.vehiclePlate, 'RYAN1234');
    expect(result.status, isTrue);
  });
}
