import 'dart:typed_data';

import '../../domain/entities/visitor_check_in_result_entity.dart';
import '../../domain/entities/visitor_check_in_submission_entity.dart';
import '../../domain/entities/visitor_delete_photo_result_entity.dart';
import '../../domain/entities/visitor_gallery_item_entity.dart';
import '../../domain/entities/visitor_lookup_entity.dart';
import '../../domain/entities/visitor_save_photo_result_entity.dart';
import '../../domain/entities/visitor_save_photo_submission_entity.dart';
import '../../domain/repositories/visitor_access_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/visitor_access_remote_data_source.dart';
import '../models/visitor_check_in_request_dto.dart';
import '../models/visitor_save_photo_request_dto.dart';

class VisitorAccessRepositoryImpl implements VisitorAccessRepository {
  VisitorAccessRepositoryImpl(
    this._remoteDataSource,
    this._authLocalDataSource,
  );

  final VisitorAccessRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to load visitor data.');
    }

    final details = await _remoteDataSource.getVisitorLookup(
      accessToken: accessToken,
      code: code,
      isCheckIn: isCheckIn,
    );
    return details.toEntity();
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to submit check-in.');
    }

    final dto = await _remoteDataSource.submitVisitorCheckIn(
      accessToken: accessToken,
      request: VisitorCheckInRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to submit check-out.');
    }

    final dto = await _remoteDataSource.submitVisitorCheckOut(
      accessToken: accessToken,
      request: VisitorCheckInRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to load visitor image.');
    }

    return _remoteDataSource.getVisitorApplicantImage(
      accessToken: accessToken,
      invitationId: invitationId,
      appId: appId,
    );
  }

  @override
  Future<List<VisitorGalleryItemEntity>> getVisitorGalleryList({
    required String invitationId,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to load visitor gallery.');
    }

    final dtos = await _remoteDataSource.getVisitorGalleryList(
      accessToken: accessToken,
      invitationId: invitationId,
    );
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }

  @override
  Future<Uint8List?> getVisitorGalleryPhoto({required int photoId}) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to load gallery photo.');
    }

    return _remoteDataSource.getVisitorGalleryPhoto(
      accessToken: accessToken,
      photoId: photoId,
    );
  }

  @override
  Future<VisitorSavePhotoResultEntity> saveVisitorPhoto({
    required VisitorSavePhotoSubmissionEntity submission,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to upload photo.');
    }

    final dto = await _remoteDataSource.saveVisitorPhoto(
      accessToken: accessToken,
      request: VisitorSavePhotoRequestDto.fromEntity(submission),
    );
    return dto.toEntity();
  }

  @override
  Future<VisitorDeletePhotoResultEntity> deleteVisitorGalleryPhoto({
    required int photoId,
  }) async {
    final session = await _authLocalDataSource.getSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Please login again to delete gallery photo.');
    }

    final dto = await _remoteDataSource.deleteVisitorGalleryPhoto(
      accessToken: accessToken,
      photoId: photoId,
    );
    return dto.toEntity();
  }
}
