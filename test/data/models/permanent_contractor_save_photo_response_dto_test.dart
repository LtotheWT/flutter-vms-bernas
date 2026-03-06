import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/permanent_contractor_save_photo_response_dto.dart';

void main() {
  test('parses contractor save photo success response', () {
    final dto = PermanentContractorSavePhotoResponseDto.fromJson({
      'success': true,
      'message': 'Photo saved successfully',
      'data': {'PhotoId': 53},
    });

    final entity = dto.toEntity();
    expect(entity.success, isTrue);
    expect(entity.message, 'Photo saved successfully');
    expect(entity.photoId, 53);
  });
}
