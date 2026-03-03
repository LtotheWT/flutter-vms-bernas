import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_gallery_item_dto.dart';

void main() {
  test('parses gallery item and maps to entity', () {
    final dto = VisitorGalleryItemDto.fromJson({
      'photoId': 29,
      'photoDesc': 'Front Gate',
      'Url': '/visitor/photo/29',
    });

    final entity = dto.toEntity();
    expect(entity.photoId, 29);
    expect(entity.photoDesc, 'Front Gate');
    expect(entity.url, '/visitor/photo/29');
  });

  test('falls back safely on invalid fields', () {
    final dto = VisitorGalleryItemDto.fromJson({
      'photoId': 'bad',
      'photoDesc': null,
      'Url': null,
    });

    expect(dto.photoId, 0);
    expect(dto.photoDesc, '');
    expect(dto.url, '');
  });
}
