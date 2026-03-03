import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_save_photo_request_dto.dart';
import 'package:vms_bernas/domain/entities/visitor_save_photo_submission_entity.dart';

void main() {
  test('toJson maps exact request keys', () {
    const entity = VisitorSavePhotoSubmissionEntity(
      imageBase64: 'abc123',
      photoDescription: 'Gate cam',
      invitationId: 'IV20260300016',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      uploadedBy: 'Ryan',
    );

    final dto = VisitorSavePhotoRequestDto.fromEntity(entity);
    final json = dto.toJson();

    expect(json, {
      'ImageBase64': 'abc123',
      'PhotoDescription': 'Gate cam',
      'InvitationId': 'IV20260300016',
      'Entity': 'AGYTEK',
      'Site': 'FACTORY1',
      'UploadedBy': 'Ryan',
    });
  });
}
