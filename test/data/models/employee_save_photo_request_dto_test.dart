import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/employee_save_photo_request_dto.dart';
import 'package:vms_bernas/domain/entities/employee_save_photo_submission_entity.dart';

void main() {
  test('maps employee photo submission to exact json keys', () {
    final dto = EmployeeSavePhotoRequestDto.fromEntity(
      const EmployeeSavePhotoSubmissionEntity(
        imageBase64: 'abc123',
        photoDescription: 'Gate',
        guid: 'guid-1',
        entity: 'AGYTEK',
        site: 'FACTORY1',
        uploadedBy: 'Ryan',
      ),
    );

    expect(dto.toJson(), {
      'ImageBase64': 'abc123',
      'PhotoDescription': 'Gate',
      'GUID': 'guid-1',
      'Entity': 'AGYTEK',
      'Site': 'FACTORY1',
      'UploadedBy': 'Ryan',
    });
  });
}
