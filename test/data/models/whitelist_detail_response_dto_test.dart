import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_detail_response_dto.dart';

void main() {
  test('parses whitelist detail wrapper success', () {
    final dto = WhitelistDetailResponseDto.fromJson({
      'Status': true,
      'Message': 'ok',
      'Details': {
        'ENTITY': 'AGYTEK',
        'WL_VEHICLE_PLATE': 'www9233G',
        'WL_IC': '123456789012',
        'WL_NAME': 'John',
        'STATUS': 'A',
        'CREATE_BY': 'admin',
        'CREATE_DATE': '2025-12-03 10:23:10',
        'UPDATE_BY': 'admin',
        'UPDATE_DATE': '2025-12-03 10:48:15',
      },
    });

    expect(dto.status, isTrue);
    expect(dto.message, 'ok');
    expect(dto.details, isNotNull);
    expect(dto.details?.status, 'ACTIVE');
    expect(dto.details?.vehiclePlate, 'www9233G');
  });

  test('parses whitelist detail wrapper failure message', () {
    final dto = WhitelistDetailResponseDto.fromJson({
      'Status': false,
      'Message': 'Not found',
      'Details': null,
    });

    expect(dto.status, isFalse);
    expect(dto.message, 'Not found');
    expect(dto.details, isNull);
  });

  test('normalizes inactive detail status', () {
    final dto = WhitelistDetailResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {
        'ENTITY': 'AGYTEK',
        'WL_VEHICLE_PLATE': 'car',
        'WL_IC': 'ic',
        'WL_NAME': 'name',
        'STATUS': 'i',
        'CREATE_BY': '',
        'CREATE_DATE': '',
        'UPDATE_BY': '',
        'UPDATE_DATE': '',
      },
    });

    expect(dto.details?.status, 'INACTIVE');
  });
}
