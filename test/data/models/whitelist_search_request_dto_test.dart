import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_search_request_dto.dart';
import 'package:vms_bernas/domain/entities/whitelist_search_filter_entity.dart';

void main() {
  test('serializes request keys with uppercased status and type', () {
    const filter = WhitelistSearchFilterEntity(
      entity: 'AGYTEK',
      currentType: 'i',
      vehiclePlate: 'ABC1234',
      ic: 'IC001',
      status: 'active',
    );

    final dto = WhitelistSearchRequestDto.fromEntity(filter);
    final json = dto.toJson();

    expect(json, {
      'Entity': 'AGYTEK',
      'CURRENT_TYPE': 'I',
      'VehiclePlate': 'ABC1234',
      'IC': 'IC001',
      'STATUS': 'ACTIVE',
    });
  });

  test('always includes STATUS key with empty string when not selected', () {
    const filter = WhitelistSearchFilterEntity(
      entity: 'AGYTEK',
      currentType: 'O',
      vehiclePlate: '',
      ic: '',
    );

    final dto = WhitelistSearchRequestDto.fromEntity(filter);
    final json = dto.toJson();

    expect(json.containsKey('STATUS'), isTrue);
    expect(json['STATUS'], '');
  });
}
