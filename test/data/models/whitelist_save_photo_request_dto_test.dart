import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_save_photo_request_dto.dart';
import 'package:vms_bernas/domain/entities/whitelist_save_photo_submission_entity.dart';

void main() {
  test('maps whitelist photo submission to exact json keys', () {
    final dto = WhitelistSavePhotoRequestDto.fromEntity(
      const WhitelistSavePhotoSubmissionEntity(
        imageBase64: 'abc',
        photoDescription: 'Gate',
        guid: 'guid-123',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(dto.toJson(), {
      'ImageBase64': 'abc',
      'PhotoDescription': 'Gate',
      'GUID': 'guid-123',
      'Entity': 'AGYTEK',
      'Site': 'FACTORY1',
      'UploadedBy': 'Ryan',
    });
  });
}
