import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/invitation_listing_request_dto.dart';

void main() {
  test('InvitationListingRequestDto serializes required keys only', () {
    const dto = InvitationListingRequestDto(
      department: 'ADC',
      visitorType: '1_Visitor',
      invitationId: 'IV20251200001',
      status: 'NEW',
      site: 'FACTORY1',
      entity: 'AGYTEK',
      userId: 'ryan',
      visitFrom: '2026-02-23T00:00:00.000Z',
      visitTo: '2026-02-23T23:59:59.999Z',
    );

    final json = dto.toJson();

    expect(json.keys, {
      'dept',
      'visitor_type',
      'inviteid',
      'status',
      'site',
      'ccn',
      'userid',
      'visit_from',
      'visit_to',
    });
    expect(json['dept'], 'ADC');
    expect(json['visitor_type'], '1_Visitor');
    expect(json['status'], 'NEW');
    expect(json['ccn'], 'AGYTEK');
    expect(json['userid'], 'ryan');
    expect(json['visit_from'], '2026-02-23T00:00:00.000Z');
    expect(json['visit_to'], '2026-02-23T23:59:59.999Z');
  });
}
