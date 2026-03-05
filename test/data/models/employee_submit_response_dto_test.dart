import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/employee_submit_response_dto.dart';

void main() {
  test('parses employee submit response with details', () {
    final dto = EmployeeSubmitResponseDto.fromJson({
      'Status': true,
      'Message': 'Employee checked in successfully.',
      'Details': {
        'EmployeeId': 'EMP0001',
        'EventType': 'IN',
        'EventDate': '2026-03-05T22:49:10.2640583+08:00',
        'PhotoGuid': 'dbcf5bb1-dbf1-45bd-94b6-632aa8af3088',
      },
    });

    expect(dto.status, isTrue);
    expect(dto.message, 'Employee checked in successfully.');
    expect(dto.eventType, 'IN');
    expect(dto.eventDate, '2026-03-05T22:49:10.2640583+08:00');
    expect(dto.photoGuid, 'dbcf5bb1-dbf1-45bd-94b6-632aa8af3088');
  });

  test('parses employee submit response when details missing', () {
    final dto = EmployeeSubmitResponseDto.fromJson({
      'Status': false,
      'Message': null,
      'Details': null,
    });

    expect(dto.status, isFalse);
    expect(dto.message, '');
    expect(dto.eventType, '');
    expect(dto.eventDate, '');
    expect(dto.photoGuid, '');
  });
}
