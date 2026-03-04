import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_submit_request_dto.dart';

void main() {
  test('serializes whitelist submit payload with exact keys', () {
    const dto = WhitelistSubmitRequestDto(
      entity: 'AGYTEK',
      site: 'FACTORY1',
      gate: 'F1_A',
      vehiclePlate: 'RYAN1234',
      createdBy: 'Ryan',
    );

    expect(dto.toJson(), {
      'Entity': 'AGYTEK',
      'Site': 'FACTORY1',
      'Gate': 'F1_A',
      'VehiclePlate': 'RYAN1234',
      'CreatedBy': 'Ryan',
    });
  });
}
