import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/employee_save_photo_response_dto.dart';

void main() {
  test('parses employee save photo response with photo id', () {
    final dto = EmployeeSavePhotoResponseDto.fromJson({
      'success': true,
      'message': 'Photo saved successfully',
      'data': {'PhotoId': 40},
    });

    expect(dto.success, isTrue);
    expect(dto.message, 'Photo saved successfully');
    expect(dto.photoId, 40);
    expect(dto.toEntity().photoId, 40);
  });

  test('handles missing data block safely', () {
    final dto = EmployeeSavePhotoResponseDto.fromJson({
      'success': true,
      'message': 'Photo saved successfully',
      'data': null,
    });

    expect(dto.success, isTrue);
    expect(dto.photoId, isNull);
  });
}
