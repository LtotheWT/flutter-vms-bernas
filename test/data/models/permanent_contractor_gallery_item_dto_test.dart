import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/permanent_contractor_gallery_item_dto.dart';

void main() {
  test('maps contractor gallery item fields', () {
    final dto = PermanentContractorGalleryItemDto.fromJson({
      'photoId': 53,
      'photoDesc': 'string',
      'Url': '/Contractor/photo/53',
    });

    final entity = dto.toEntity();
    expect(entity.photoId, 53);
    expect(entity.photoDesc, 'string');
    expect(entity.url, '/Contractor/photo/53');
  });
}
