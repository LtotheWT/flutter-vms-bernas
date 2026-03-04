import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/dashboard_io_metric_dto.dart';

void main() {
  test('parses int and string values safely', () {
    final dto = DashboardIoMetricDto.fromJson({
      'Entity': 'AGYTEK',
      'TotalInRecords': '839',
      'TotalOutRecords': 661,
      'StillInCount': null,
    });

    expect(dto.entity, 'AGYTEK');
    expect(dto.totalInRecords, 839);
    expect(dto.totalOutRecords, 661);
    expect(dto.stillInCount, 0);
  });
}
