import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/ref_entity_dto.dart';

void main() {
  test('parses normal entity row', () {
    const json = {'entity': 'AGYTEK', 'entity_name': 'AGYTEK - Agytek1231'};

    final dto = RefEntityDto.fromJson(json);

    expect(dto.entity, 'AGYTEK');
    expect(dto.entityName, 'AGYTEK - Agytek1231');
    expect(dto.toEntity().code, 'AGYTEK');
  });

  test('keeps blank row values from API', () {
    const json = {'entity': '', 'entity_name': ''};

    final dto = RefEntityDto.fromJson(json);

    expect(dto.entity, isEmpty);
    expect(dto.entityName, isEmpty);
  });
}
