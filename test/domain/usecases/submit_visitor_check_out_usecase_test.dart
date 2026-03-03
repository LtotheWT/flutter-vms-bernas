import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_result_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_gallery_item_entity.dart';
import 'package:vms_bernas/domain/entities/visitor_lookup_entity.dart';
import 'package:vms_bernas/domain/repositories/visitor_access_repository.dart';
import 'package:vms_bernas/domain/usecases/submit_visitor_check_out_usecase.dart';

class _FakeVisitorAccessRepository implements VisitorAccessRepository {
  VisitorCheckInSubmissionEntity? capturedSubmission;

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckOut({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    capturedSubmission = submission;
    return const VisitorCheckInResultEntity(
      status: true,
      message: 'Checked-out successfully.',
    );
  }

  @override
  Future<VisitorCheckInResultEntity> submitVisitorCheckIn({
    required VisitorCheckInSubmissionEntity submission,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getVisitorApplicantImage({
    required String invitationId,
    required String appId,
  }) async {
    return null;
  }

  @override
  Future<List<VisitorGalleryItemEntity>> getVisitorGalleryList({
    required String invitationId,
  }) async {
    return const <VisitorGalleryItemEntity>[];
  }

  @override
  Future<Uint8List?> getVisitorGalleryPhoto({required int photoId}) async {
    return null;
  }
}

void main() {
  test('forwards submission to repository', () async {
    final repository = _FakeVisitorAccessRepository();
    final useCase = SubmitVisitorCheckOutUseCase(repository);
    const submission = VisitorCheckInSubmissionEntity(
      userId: 'Ryan',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      gate: 'F1_A',
      invitationId: 'IV20260200038',
      visitors: [
        VisitorCheckInSubmissionItemEntity(
          appId: '123456561231',
          physicalTag: '',
        ),
      ],
    );

    final result = await useCase(submission: submission);

    expect(repository.capturedSubmission, submission);
    expect(result.status, isTrue);
  });
}
