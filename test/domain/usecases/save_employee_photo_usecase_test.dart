import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/employee_delete_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/employee_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/employee_info_entity.dart';
import 'package:vms_bernas/domain/entities/employee_save_photo_result_entity.dart';
import 'package:vms_bernas/domain/entities/employee_save_photo_submission_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';
import 'package:vms_bernas/domain/entities/employee_submit_result_entity.dart';
import 'package:vms_bernas/domain/repositories/employee_access_repository.dart';
import 'package:vms_bernas/domain/usecases/save_employee_photo_usecase.dart';

class _FakeEmployeeAccessRepository implements EmployeeAccessRepository {
  EmployeeSavePhotoSubmissionEntity? lastSubmission;

  @override
  Future<EmployeeSavePhotoResultEntity> saveEmployeePhoto({
    required EmployeeSavePhotoSubmissionEntity submission,
  }) async {
    lastSubmission = submission;
    return const EmployeeSavePhotoResultEntity(
      success: true,
      message: 'Photo saved successfully',
      photoId: 40,
    );
  }

  @override
  Future<EmployeeDeletePhotoResultEntity> deleteEmployeeGalleryPhoto({
    required int photoId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmployeeGalleryItemEntity>> getEmployeeGalleryList({
    required String guid,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getEmployeeGalleryPhoto({required int photoId}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getEmployeeImage({required String employeeId}) {
    throw UnimplementedError();
  }

  @override
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code}) {
    throw UnimplementedError();
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckIn({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('forwards employee photo submission to repository', () async {
    final repository = _FakeEmployeeAccessRepository();
    final useCase = SaveEmployeePhotoUseCase(repository);

    final submission = const EmployeeSavePhotoSubmissionEntity(
      imageBase64: 'abc',
      photoDescription: 'Gate',
      guid: 'guid-1',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      uploadedBy: 'Ryan',
    );
    final result = await useCase(submission: submission);

    expect(repository.lastSubmission, submission);
    expect(result.success, isTrue);
    expect(result.photoId, 40);
  });
}
