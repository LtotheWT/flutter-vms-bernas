import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/save_visitor_photo_usecase.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  VisitorSavePhotoSubmissionEntity? capturedSubmission;

  @override
  Future<VisitorSavePhotoResultEntity> saveVisitorPhoto({
    required VisitorSavePhotoSubmissionEntity submission,
  }) async {
    capturedSubmission = submission;
    return const VisitorSavePhotoResultEntity(
      success: true,
      message: 'Photo saved successfully',
      photoId: 29,
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
}

void main() {
  test('forwards save-photo submission to repository', () async {
    final repository = _FakeVisitorAccessRepository();
    final useCase = SaveVisitorPhotoUseCase(repository);

    final result = await useCase(
      submission: const VisitorSavePhotoSubmissionEntity(
        imageBase64: 'abc',
        photoDescription: 'desc',
        invitationId: 'IV20260300016',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(repository.capturedSubmission?.uploadedBy, 'Ryan');
    expect(result.success, isTrue);
    expect(result.photoId, 29);
  });
}
