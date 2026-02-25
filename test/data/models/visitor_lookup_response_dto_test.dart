import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_lookup_response_dto.dart';

void main() {
  test('parses success payload with details', () {
    const json = {
      'Status': true,
      'Message': null,
      'Details': {
        'invitationId': 'IV20260200038',
        'entity': 'AGYTEK',
        'site': 'FACTORY1',
        'visitorType': '1_Visitor',
        'visitorList': [
          {'name': 'NAME', 'icPassport': '123'},
        ],
      },
    };

    final dto = VisitorLookupResponseDto.fromJson(json);

    expect(dto.status, isTrue);
    expect(dto.message, isNull);
    expect(dto.details, isNotNull);
    expect(dto.details?.invitationId, 'IV20260200038');
    expect(dto.details?.visitorList, hasLength(1));
  });

  test('parses failure payload and keeps message', () {
    const json = {'Status': false, 'Message': 'Invalid code', 'Details': null};

    final dto = VisitorLookupResponseDto.fromJson(json);

    expect(dto.status, isFalse);
    expect(dto.message, 'Invalid code');
    expect(dto.details, isNull);
  });
}
