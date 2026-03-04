import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/dashboard_summary_response_dto.dart';

void main() {
  test('parses success response and matches requested entity row', () {
    final dto = DashboardSummaryResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {
        'VisitorIO': [
          {
            'Entity': 'OTHER',
            'TotalInRecords': 1,
            'TotalOutRecords': 1,
            'StillInCount': 0,
          },
          {
            'Entity': 'AGYTEK',
            'TotalInRecords': 839,
            'TotalOutRecords': 661,
            'StillInCount': 178,
          },
        ],
        'ContrIO': [
          {
            'Entity': 'AGYTEK',
            'TotalInRecords': 36,
            'TotalOutRecords': 30,
            'StillInCount': 6,
          },
        ],
        'WhitelistIO': [
          {
            'Entity': 'AGYTEK',
            'TotalInRecords': 38,
            'TotalOutRecords': 38,
            'StillInCount': 0,
          },
        ],
      },
    }, requestedEntity: 'AGYTEK');

    expect(dto.status, isTrue);
    expect(dto.visitor.totalInRecords, 839);
    expect(dto.contractor.totalOutRecords, 30);
    expect(dto.whitelist.stillInCount, 0);
  });

  test('falls back to first row when requested entity not found', () {
    final dto = DashboardSummaryResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {
        'VisitorIO': [
          {
            'Entity': 'ABC',
            'TotalInRecords': 5,
            'TotalOutRecords': 3,
            'StillInCount': 2,
          },
        ],
        'ContrIO': [],
        'WhitelistIO': [],
      },
    }, requestedEntity: 'AGYTEK');

    expect(dto.visitor.entity, 'ABC');
    expect(dto.visitor.totalInRecords, 5);
  });

  test('missing arrays map to zero metrics', () {
    final dto = DashboardSummaryResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {},
    }, requestedEntity: 'AGYTEK');

    expect(dto.visitor.entity, 'AGYTEK');
    expect(dto.visitor.totalInRecords, 0);
    expect(dto.contractor.totalOutRecords, 0);
    expect(dto.whitelist.stillInCount, 0);
  });
}
