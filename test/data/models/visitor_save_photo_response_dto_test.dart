import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_save_photo_response_dto.dart';

void main() {
  test('parses success with photo id', () {
    final dto = VisitorSavePhotoResponseDto.fromJson({
      'success': true,
      'message': 'Photo saved successfully',
      'data': {'PhotoId': 29},
    });

    expect(dto.success, isTrue);
    expect(dto.message, 'Photo saved successfully');
    expect(dto.photoId, 29);
  });

  test('parses success when data missing', () {
    final dto = VisitorSavePhotoResponseDto.fromJson({
      'success': true,
      'message': null,
    });

    final entity = dto.toEntity();
    expect(entity.success, isTrue);
    expect(entity.message, '');
    expect(entity.photoId, isNull);
  });

  test('parses failure with message', () {
    final dto = VisitorSavePhotoResponseDto.fromJson({
      'success': false,
      'message': 'Invalid image payload',
      'data': {},
    });

    expect(dto.success, isFalse);
    expect(dto.message, 'Invalid image payload');
    expect(dto.photoId, isNull);
  });
}
