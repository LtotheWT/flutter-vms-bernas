import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/employee_submit_request_dto.dart';
import 'package:vms_bernas/domain/entities/employee_submit_entity.dart';

void main() {
  test('maps employee submit entity to exact request keys', () {
    final dto = EmployeeSubmitRequestDto.fromEntity(
      const EmployeeSubmitEntity(
        employeeId: 'EMP0001',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
    );

    expect(dto.toJson(), {
      'EmployeeId': 'EMP0001',
      'Site': 'FACTORY1',
      'Gate': 'F1_A',
      'CreatedBy': 'Ryan',
    });
  });
}
