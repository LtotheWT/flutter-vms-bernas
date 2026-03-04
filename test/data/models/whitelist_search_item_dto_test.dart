import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_search_item_dto.dart';

void main() {
  test('maps response fields and normalizes A/I status', () {
    final dto = WhitelistSearchItemDto.fromJson({
      'ENTITY': 'AGYTEK',
      'WL_VEHICLE_PLATE': 'RYAN1234',
      'WL_IC': 'RYAN',
      'WL_NAME': 'RYAN1234',
      'STATUS': 'A',
      'CREATE_BY': 'ryan',
      'CREATE_DATE': '2026-01-13 11:46:40',
      'UPDATE_BY': null,
      'UPDATE_DATE': null,
    });

    final entity = dto.toEntity();
    expect(entity.entity, 'AGYTEK');
    expect(entity.vehiclePlate, 'RYAN1234');
    expect(entity.ic, 'RYAN');
    expect(entity.name, 'RYAN1234');
    expect(entity.status, 'ACTIVE');
    expect(entity.createBy, 'ryan');
    expect(entity.updateBy, '');
  });

  test('normalizes INACTIVE variations', () {
    final shortDto = WhitelistSearchItemDto.fromJson({'STATUS': 'I'});
    final fullDto = WhitelistSearchItemDto.fromJson({'STATUS': 'inactive'});

    expect(shortDto.status, 'INACTIVE');
    expect(fullDto.status, 'INACTIVE');
  });
}
