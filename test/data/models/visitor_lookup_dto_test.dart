import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_lookup_dto.dart';

void main() {
  test('maps lookup dto to entity with fallback-safe strings', () {
    const json = {
      'invitationId': 'IV20260200038',
      'entity': 'AGYTEK',
      'site': 'FACTORY1',
      'siteDesc': 'FACTORY1 T',
      'department': 'ADC',
      'departmentDesc': 'ADMIN CENTER',
      'purpose': 'MEETING',
      'company': 'TEST',
      'contactNumber': '0123456789',
      'visitorType': '1_Visitor',
      'inviteBy': 'Suraya',
      'workLevel': '',
      'vehiclePlateNumber': 'WWW0000',
      'status': 'ARRIVED',
      'visitDateFrom': '2026-02-25T00:00:00',
      'visitDateTo': '2026-02-25T00:00:00',
      'visitTimeFrom': '19:00:PM',
      'visitTimeTo': '20:00:PM',
      'visitorList': [
        {
          'name': 'NAME',
          'icPassport': '12345656123',
          'physicalTag': 'KAK -V036',
          'checkInTime': '2026-02-25T17:27:39.723',
          'checkOutTime': null,
        },
      ],
    };

    final dto = VisitorLookupDto.fromJson(json);
    final entity = dto.toEntity();

    expect(entity.invitationId, 'IV20260200038');
    expect(entity.siteDesc, 'FACTORY1 T');
    expect(entity.visitors, hasLength(1));
    expect(entity.visitors.first.name, 'NAME');
    expect(entity.visitors.first.checkOutTime, '');
  });
}
