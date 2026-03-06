import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/permanent_contractor_save_photo_request_dto.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_save_photo_submission_entity.dart';

void main() {
  test('serializes contractor save photo payload with exact keys', () {
    final dto = PermanentContractorSavePhotoRequestDto.fromEntity(
      const PermanentContractorSavePhotoSubmissionEntity(
        imageBase64: 'abc',
        photoDescription: 'Gate shot',
        guid: 'guid-1',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(dto.toJson(), {
      'ImageBase64': 'abc',
      'PhotoDescription': 'Gate shot',
      'GUID': 'guid-1',
      'Entity': 'AGYTEK',
      'Site': 'FACTORY1',
      'UploadedBy': 'Ryan',
    });
  });
}
