import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/invitation_listing_item_dto.dart';

void main() {
  test('InvitationListingItemDto parses fields and maps fallback company', () {
    final dto = InvitationListingItemDto.fromJson({
      'Entity': 'AGYTEK',
      'Site': 'FACTORY1',
      'InvitationId': 'IV20251200001',
      'Department': 'ADC',
      'InviteBy': 'EMP0001',
      'CreateBy': 'admin',
      'VisitorType': '1_Visitor',
      'Company': null,
      'CompanyVisitorName': 'RUFI TEST 1',
      'VehiclePlate': null,
      'Status': 'NEW',
      'Purpose': 'RUFI TEST 1',
      'VisitDateFrom': '2025-12-09',
      'VisitTimeFrom': '07:00:AM',
      'VisitDateTo': '2025-12-09',
      'VisitTimeTo': '16:00:PM',
      'CreateDate': '2025-12-09T01:59:06.877',
      'UpdateDate': null,
      'UpdateBy': null,
    });

    final entity = dto.toEntity();

    expect(entity.invitationId, 'IV20251200001');
    expect(entity.inviteBy, 'EMP0001');
    expect(entity.company, 'RUFI TEST 1');
    expect(entity.vehiclePlateNumber, '');
    expect(entity.statusCode, 'NEW');
  });
}
