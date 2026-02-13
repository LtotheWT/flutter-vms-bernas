import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/invitation_create_request_dto.dart';

void main() {
  test('serializes invitation create request payload', () {
    const dto = InvitationCreateRequestDto(
      ccn: 'AGYTEK',
      userId: 'ryan',
      site: 'FACTORY1',
      dept: 'ADC',
      employee: 'EMP0001',
      visitorType: '1_Visitor',
      visitorName: 'Suraya',
      purpose: 'Meeting',
      invitePurpose: 'Meeting',
      email: 'a@b.com',
      visitFrom: '2026-02-13T08:24:06.452Z',
      visitTo: '2026-02-13T09:24:06.452Z',
    );

    final json = dto.toJson();

    expect(json['ccn'], 'AGYTEK');
    expect(json['userid'], 'ryan');
    expect(json['site'], 'FACTORY1');
    expect(json['dept'], 'ADC');
    expect(json['employee'], 'EMP0001');
    expect(json['visitor_type'], '1_Visitor');
    expect(json['visitor_name'], 'Suraya');
    expect(json['purpose'], 'Meeting');
    expect(json['invite_purpose'], 'Meeting');
    expect(json['email'], 'a@b.com');
    expect(json['visit_from'], '2026-02-13T08:24:06.452Z');
    expect(json['visit_to'], '2026-02-13T09:24:06.452Z');
  });
}
