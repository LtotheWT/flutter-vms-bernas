import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/ref_location_dto.dart';

void main() {
  test('parses normal location row', () {
    const json = {'site': 'FACTORY1', 'site_desc': 'FACTORY1 - FACTORY1 T'};

    final dto = RefLocationDto.fromJson(json);

    expect(dto.site, 'FACTORY1');
    expect(dto.siteDesc, 'FACTORY1 - FACTORY1 T');
    expect(dto.toEntity().site, 'FACTORY1');
  });

  test('keeps blank location row values from API', () {
    const json = {'site': '', 'site_desc': ''};

    final dto = RefLocationDto.fromJson(json);

    expect(dto.site, isEmpty);
    expect(dto.siteDesc, isEmpty);
  });
}
