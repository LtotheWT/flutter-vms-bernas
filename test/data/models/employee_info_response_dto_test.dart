import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/employee_info_response_dto.dart';

void main() {
  test('parses employee lookup response wrapper and details', () {
    final dto = EmployeeInfoResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {
        'EMP_ID': 'EMP0001',
        'EMP_NAME': 'Suraya',
        'SITE': 'FACTORY1',
        'DEPT': 'ADC',
        'UNIT': 'ABC',
        'VEHICLE_TYPE': 'CAR',
        'HP_NO': '0123456789',
        'TEL_NO': '03-1234',
        'START_WORKING_DATE': '2025-11-01T00:00:00',
        'LAST_WORKING_DATE': '2025-11-30T00:00:00',
      },
    });

    expect(dto.status, isTrue);
    expect(dto.message, isNull);
    final details = dto.details;
    expect(details, isNotNull);
    expect(details?.employeeId, 'EMP0001');
    expect(details?.employeeName, 'Suraya');
    expect(details?.site, 'FACTORY1');
    expect(details?.department, 'ADC');
    expect(details?.unit, 'ABC');
    expect(details?.vehicleType, 'CAR');
    expect(details?.handphoneNo, '0123456789');
    expect(details?.telNoExtension, '03-1234');
    expect(details?.effectiveWorkingDate, '2025-11-01T00:00:00');
    expect(details?.lastWorkingDate, '2025-11-30T00:00:00');
  });
}
