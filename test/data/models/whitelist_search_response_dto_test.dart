import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_search_response_dto.dart';

void main() {
  test('parses wrapper success with details list', () {
    final dto = WhitelistSearchResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': [
        {
          'ENTITY': 'AGYTEK',
          'WL_VEHICLE_PLATE': 'RYAN1234',
          'WL_IC': 'RYAN',
          'WL_NAME': 'RYAN1234',
          'STATUS': 'A',
          'CREATE_BY': 'ryan',
          'CREATE_DATE': '2026-01-13 11:46:40',
          'UPDATE_BY': null,
          'UPDATE_DATE': null,
        },
      ],
    });

    expect(dto.status, isTrue);
    expect(dto.message, isNull);
    expect(dto.details, hasLength(1));
    expect(dto.details.first.status, 'ACTIVE');
  });

  test('parses wrapper failure with backend message', () {
    final dto = WhitelistSearchResponseDto.fromJson({
      'Status': false,
      'Message': 'Invalid operation',
      'Details': [],
    });

    expect(dto.status, isFalse);
    expect(dto.message, 'Invalid operation');
    expect(dto.details, isEmpty);
  });
}
