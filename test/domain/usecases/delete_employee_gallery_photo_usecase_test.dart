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
import 'package:vms_bernas/domain/usecases/delete_employee_gallery_photo_usecase.dart';

class _FakeEmployeeAccessRepository implements EmployeeAccessRepository {
  int? lastPhotoId;

  @override
  Future<EmployeeDeletePhotoResultEntity> deleteEmployeeGalleryPhoto({
    required int photoId,
  }) async {
    lastPhotoId = photoId;
    return const EmployeeDeletePhotoResultEntity(
      success: true,
      message: 'delete is successful',
    );
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
  Future<EmployeeSavePhotoResultEntity> saveEmployeePhoto({
    required EmployeeSavePhotoSubmissionEntity submission,
  }) {
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
  test('forwards employee gallery photo delete to repository', () async {
    final repository = _FakeEmployeeAccessRepository();
    final useCase = DeleteEmployeeGalleryPhotoUseCase(repository);

    final result = await useCase(photoId: 40);

    expect(repository.lastPhotoId, 40);
    expect(result.success, isTrue);
  });
}
