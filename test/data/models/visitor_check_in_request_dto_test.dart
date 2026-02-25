import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_check_in_request_dto.dart';
import 'package:vms_bernas/domain/entities/visitor_check_in_submission_item_entity.dart';

void main() {
  test('serializes required payload keys for visitor check-in', () {
    const dto = VisitorCheckInRequestDto(
      userId: 'Ryan',
      entity: 'AGYTEK',
      site: 'FACTORY1',
      gate: 'F1_A',
      invitationId: 'IV20260200038',
      visitors: [
        VisitorCheckInSubmissionItemEntity(
          appId: '123456561231',
          physicalTag: '',
        ),
      ],
    );

    final json = dto.toJson();
    expect(json.keys, {
      'userId',
      'entity',
      'site',
      'gate',
      'invitationid',
      'Visitors',
    });
    expect(json['userId'], 'Ryan');
    expect(json['entity'], 'AGYTEK');
    expect(json['site'], 'FACTORY1');
    expect(json['gate'], 'F1_A');
    expect(json['invitationid'], 'IV20260200038');
    expect(json['Visitors'], [
      {'app_id': '123456561231', 'physical_tag': ''},
    ]);
  });
}
