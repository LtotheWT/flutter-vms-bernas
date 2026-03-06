import 'dart:typed_data';

import '../entities/employee_delete_photo_result_entity.dart';
import '../entities/employee_gallery_item_entity.dart';
import '../entities/employee_info_entity.dart';
import '../entities/employee_save_photo_result_entity.dart';
import '../entities/employee_save_photo_submission_entity.dart';
import '../entities/employee_submit_entity.dart';
import '../entities/employee_submit_result_entity.dart';

abstract class EmployeeAccessRepository {
  Future<EmployeeInfoEntity> getEmployeeInfo({required String code});

  Future<Uint8List?> getEmployeeImage({required String employeeId});

  Future<List<EmployeeGalleryItemEntity>> getEmployeeGalleryList({
    required String guid,
  });

  Future<Uint8List?> getEmployeeGalleryPhoto({required int photoId});

  Future<EmployeeSavePhotoResultEntity> saveEmployeePhoto({
    required EmployeeSavePhotoSubmissionEntity submission,
  });

  Future<EmployeeDeletePhotoResultEntity> deleteEmployeeGalleryPhoto({
    required int photoId,
  });

  Future<EmployeeSubmitResultEntity> submitEmployeeCheckIn({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  });

  Future<EmployeeSubmitResultEntity> submitEmployeeCheckOut({
    required EmployeeSubmitEntity submission,
    required String idempotencyKey,
  });
}
