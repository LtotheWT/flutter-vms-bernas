import '../entities/ref_entity_entity.dart';
import '../entities/ref_department_entity.dart';
import '../entities/ref_location_entity.dart';
import '../entities/ref_personel_entity.dart';
import '../entities/ref_visitor_type_entity.dart';
import '../entities/permanent_contractor_info_entity.dart';
import '../entities/permanent_contractor_gallery_item_entity.dart';
import '../entities/permanent_contractor_save_photo_submission_entity.dart';
import '../entities/permanent_contractor_save_photo_result_entity.dart';
import '../entities/permanent_contractor_delete_photo_result_entity.dart';
import '../entities/permanent_contractor_submit_entity.dart';
import '../entities/permanent_contractor_submit_result_entity.dart';
import '../entities/dashboard_summary_entity.dart';
import 'dart:typed_data';

abstract class ReferenceRepository {
  Future<List<RefEntityEntity>> getEntities();

  Future<List<RefDepartmentEntity>> getDepartments({required String entity});

  Future<List<RefLocationEntity>> getLocations({required String entity});

  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  });

  Future<List<RefVisitorTypeEntity>> getVisitorTypes();

  Future<DashboardSummaryEntity> getDashboardSummary({required String entity});

  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  });

  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  });

  Future<List<PermanentContractorGalleryItemEntity>>
  getPermanentContractorGalleryList({required String guid});

  Future<Uint8List?> getPermanentContractorGalleryPhoto({required int photoId});

  Future<PermanentContractorSavePhotoResultEntity>
  savePermanentContractorPhoto({
    required PermanentContractorSavePhotoSubmissionEntity submission,
  });

  Future<PermanentContractorDeletePhotoResultEntity>
  deletePermanentContractorGalleryPhoto({required int photoId});

  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckIn({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  });

  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  });
}
