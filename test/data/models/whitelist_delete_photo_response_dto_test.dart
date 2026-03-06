import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_delete_photo_response_dto.dart';

void main() {
  test('parses wrapper delete response', () {
    final dto = WhitelistDeletePhotoResponseDto.fromJson({
      'Status': true,
      'Message': 'delete is successful',
      'Details': null,
    });

    expect(dto.status, isTrue);
    expect(dto.message, 'delete is successful');
    expect(dto.toEntity().success, isTrue);
  });
}
