import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/permanent_contractor_delete_photo_response_dto.dart';

void main() {
  test('parses contractor delete photo wrapper response', () {
    final dto = PermanentContractorDeletePhotoResponseDto.fromJson({
      'Status': true,
      'Message': 'delete is successful',
      'Details': null,
    });

    final entity = dto.toEntity();
    expect(entity.success, isTrue);
    expect(entity.message, 'delete is successful');
  });
}
