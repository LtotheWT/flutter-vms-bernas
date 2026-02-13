import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/ref_personel_dto.dart';

void main() {
  test('parses normal personel row', () {
    const json = {
      'emp_id': 'EMP0001',
      'emp_name': 'Suraya',
      'dept': 'ADC',
      'entity': 'AGYTEK',
    };

    final dto = RefPersonelDto.fromJson(json);

    expect(dto.empId, 'EMP0001');
    expect(dto.empName, 'Suraya');
    expect(dto.dept, 'ADC');
    expect(dto.entity, 'AGYTEK');
    expect(dto.toEntity().employeeId, 'EMP0001');
  });

  test('keeps blank personel row values from API', () {
    const json = {'emp_id': '', 'emp_name': '', 'dept': '', 'entity': ''};

    final dto = RefPersonelDto.fromJson(json);

    expect(dto.empId, isEmpty);
    expect(dto.empName, isEmpty);
    expect(dto.dept, isEmpty);
    expect(dto.entity, isEmpty);
  });
}
