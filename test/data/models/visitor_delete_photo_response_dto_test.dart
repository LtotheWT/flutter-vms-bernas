import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_delete_photo_response_dto.dart';

void main() {
  test('parses lowercase success response', () {
    final dto = VisitorDeletePhotoResponseDto.fromJson({
      'success': true,
      'message': 'Deleted',
    });
    expect(dto.status, isTrue);
    expect(dto.message, 'Deleted');
  });

  test('parses uppercase success response', () {
    final dto = VisitorDeletePhotoResponseDto.fromJson({
      'Success': true,
      'Message': 'Deleted',
    });
    expect(dto.status, isTrue);
    expect(dto.message, 'Deleted');
  });

  test('maps empty message safely', () {
    final dto = VisitorDeletePhotoResponseDto.fromJson({
      'success': false,
      'message': null,
    });
    final entity = dto.toEntity();
    expect(entity.success, isFalse);
    expect(entity.message, '');
  });
}
