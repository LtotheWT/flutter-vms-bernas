import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/delete_visitor_gallery_photo_usecase.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  int? capturedPhotoId;

  @override
  Future<VisitorDeletePhotoResultEntity> deleteVisitorGalleryPhoto({
    required int photoId,
  }) async {
    capturedPhotoId = photoId;
    return const VisitorDeletePhotoResultEntity(
      success: true,
      message: 'Deleted',
    );
  }

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<VisitorGalleryItemEntity>> getVisitorGalleryList({
    required String invitationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getVisitorGalleryPhoto({required int photoId}) {
    throw UnimplementedError();
  }

  @override
  Future<VisitorSavePhotoResultEntity> saveVisitorPhoto({
    required VisitorSavePhotoSubmissionEntity submission,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('forwards photo id to repository', () async {
    final repository = _FakeVisitorAccessRepository();
    final useCase = DeleteVisitorGalleryPhotoUseCase(repository);

    final result = await useCase(photoId: 32);
    expect(repository.capturedPhotoId, 32);
    expect(result.success, isTrue);
  });
}
