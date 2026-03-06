import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/employee_gallery_item_dto.dart';

void main() {
  test('parses employee gallery item payload', () {
    final dto = EmployeeGalleryItemDto.fromJson({
      'photoId': 40,
      'photoDesc': 'Gate photo',
      'Url': '/Employee/photo/40',
    });

    expect(dto.photoId, 40);
    expect(dto.photoDesc, 'Gate photo');
    expect(dto.url, '/Employee/photo/40');
    expect(dto.toEntity().photoId, 40);
  });
}
