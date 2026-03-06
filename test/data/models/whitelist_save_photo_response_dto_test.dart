import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_save_photo_response_dto.dart';

void main() {
  test('parses whitelist save photo response with photo id', () {
    final dto = WhitelistSavePhotoResponseDto.fromJson({
      'success': true,
      'message': 'Photo saved successfully',
      'data': {'PhotoId': 31},
    });

    expect(dto.success, isTrue);
    expect(dto.message, 'Photo saved successfully');
    expect(dto.photoId, 31);
    expect(dto.toEntity().photoId, 31);
  });

  test('handles missing data block safely', () {
    final dto = WhitelistSavePhotoResponseDto.fromJson({
      'success': true,
      'message': null,
      'data': null,
    });

    expect(dto.photoId, isNull);
    expect(dto.toEntity().message, '');
  });
}
