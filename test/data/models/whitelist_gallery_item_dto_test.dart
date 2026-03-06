import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_gallery_item_dto.dart';

void main() {
  test('parses whitelist gallery item payload', () {
    final dto = WhitelistGalleryItemDto.fromJson({
      'photoId': 31,
      'photoDesc': 'Front gate',
      'Url': '/Whitelist/photo/31',
    });

    expect(dto.photoId, 31);
    expect(dto.photoDesc, 'Front gate');
    expect(dto.url, '/Whitelist/photo/31');
    expect(dto.toEntity().photoId, 31);
  });
}
