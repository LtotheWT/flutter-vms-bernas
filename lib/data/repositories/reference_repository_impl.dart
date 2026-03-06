import '../../domain/entities/ref_department_entity.dart';
import '../../domain/entities/ref_entity_entity.dart';
import '../../domain/entities/ref_location_entity.dart';
import '../../domain/entities/permanent_contractor_info_entity.dart';
import '../../domain/entities/permanent_contractor_gallery_item_entity.dart';
import '../../domain/entities/permanent_contractor_save_photo_result_entity.dart';
import '../../domain/entities/permanent_contractor_save_photo_submission_entity.dart';
import '../../domain/entities/permanent_contractor_delete_photo_result_entity.dart';
import '../../domain/entities/permanent_contractor_submit_entity.dart';
import '../../domain/entities/permanent_contractor_submit_result_entity.dart';
import '../../domain/entities/ref_personel_entity.dart';
import '../../domain/entities/ref_visitor_type_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/repositories/reference_repository.dart';
import 'dart:typed_data';
import '../datasources/auth_local_data_source.dart';
import '../datasources/reference_remote_data_source.dart';
import '../models/permanent_contractor_save_photo_request_dto.dart';
import '../models/permanent_contractor_submit_request_dto.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._remoteDataSource, this._authLocalDataSource);

  final ReferenceRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<List<RefEntityEntity>> getEntities() async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load entities.',
    );
    final items = await _remoteDataSource.getEntities(accessToken: accessToken);
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<RefDepartmentEntity>> getDepartments({
    required String entity,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load departments.',
    );
    final items = await _remoteDataSource.getDepartments(
      accessToken: accessToken,
      entity: entity,
    );
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<RefLocationEntity>> getLocations({required String entity}) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load locations.',
    );
    final items = await _remoteDataSource.getLocations(
      accessToken: accessToken,
      entity: entity,
    );
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<RefPersonelEntity>> getPersonels({
    required String entity,
    required String site,
    required String department,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load hosts.',
    );
    final items = await _remoteDataSource.getPersonels(
      accessToken: accessToken,
      entity: entity,
      site: site,
      department: department,
    );
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<RefVisitorTypeEntity>> getVisitorTypes() async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load visitor types.',
    );
    final items = await _remoteDataSource.getVisitorTypes(
      accessToken: accessToken,
    );
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<DashboardSummaryEntity> getDashboardSummary({
    required String entity,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load dashboard data.',
    );
    final dto = await _remoteDataSource.getDashboardSummary(
      accessToken: accessToken,
      entity: entity,
    );
    return dto.toEntity();
  }

  @override
  Future<PermanentContractorInfoEntity> getPermanentContractorInfo({
    required String code,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load permanent contractor info.',
    );
    final item = await _remoteDataSource.getPermanentContractorInfo(
      accessToken: accessToken,
      code: code,
    );
    return item.toEntity();
  }

  @override
  Future<Uint8List?> getPermanentContractorImage({
    required String contractorId,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to load permanent contractor image.',
    );
    return _remoteDataSource.getPermanentContractorImage(
      accessToken: accessToken,
      contractorId: contractorId,
    );
  }

  @override
  Future<List<PermanentContractorGalleryItemEntity>>
  getPermanentContractorGalleryList({required String guid}) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage:
          'Please login again to load permanent contractor gallery.',
    );
    final dtos = await _remoteDataSource.getPermanentContractorGalleryList(
      accessToken: accessToken,
      guid: guid,
    );
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }

  @override
  Future<Uint8List?> getPermanentContractorGalleryPhoto({
    required int photoId,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage:
          'Please login again to load permanent contractor gallery photo.',
    );
    return _remoteDataSource.getPermanentContractorGalleryPhoto(
      accessToken: accessToken,
      photoId: photoId,
    );
  }

  @override
  Future<PermanentContractorSavePhotoResultEntity>
  savePermanentContractorPhoto({
    required PermanentContractorSavePhotoSubmissionEntity submission,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage: 'Please login again to upload photo.',
    );
    final dto = await _remoteDataSource.savePermanentContractorPhoto(
      accessToken: accessToken,
      request: PermanentContractorSavePhotoRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  @override
  Future<PermanentContractorDeletePhotoResultEntity>
  deletePermanentContractorGalleryPhoto({required int photoId}) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage:
          'Please login again to delete permanent contractor photo.',
    );
    final dto = await _remoteDataSource.deletePermanentContractorGalleryPhoto(
      accessToken: accessToken,
      photoId: photoId,
    );
    return dto.toEntity();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckIn({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage:
          'Please login again to submit permanent contractor check-in.',
    );

    final dto = await _remoteDataSource.submitPermanentContractorCheckIn(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: PermanentContractorSubmitRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  @override
  Future<PermanentContractorSubmitResultEntity>
  submitPermanentContractorCheckOut({
    required PermanentContractorSubmitEntity submission,
    required String idempotencyKey,
  }) async {
    final accessToken = await _getAccessTokenOrThrow(
      missingMessage:
          'Please login again to submit permanent contractor check-out.',
    );

    final dto = await _remoteDataSource.submitPermanentContractorCheckOut(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      request: PermanentContractorSubmitRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  Future<String> _getAccessTokenOrThrow({
    required String missingMessage,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception(missingMessage);
    }
    return accessToken;
  }
}
