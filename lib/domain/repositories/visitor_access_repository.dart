import 'dart:typed_data';

import '../entities/visitor_check_in_result_entity.dart';
import '../entities/visitor_check_in_submission_entity.dart';
import '../entities/visitor_gallery_item_entity.dart';
import '../entities/visitor_lookup_entity.dart';

abstract class VisitorAccessRepository {
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  });

  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  });

  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  });

  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  });

  Future<List<VisitorGalleryItemEntity>> getVisitorGalleryList({
    required String invitationId,
  });

  Future<Uint8List?> getVisitorGalleryPhoto({required int photoId});
}
