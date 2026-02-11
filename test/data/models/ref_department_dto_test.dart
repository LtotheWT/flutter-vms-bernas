import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/ref_department_dto.dart';

void main() {
  test('parses normal department row', () {
    const json = {'dept': 'ADC', 'dept_desc': 'ADC - ADMIN CENTER'};

    final dto = RefDepartmentDto.fromJson(json);

    expect(dto.dept, 'ADC');
    expect(dto.deptDesc, 'ADC - ADMIN CENTER');
    expect(dto.toEntity().code, 'ADC');
  });

  test('keeps blank department row values from API', () {
    const json = {'dept': '', 'dept_desc': ''};

    final dto = RefDepartmentDto.fromJson(json);

    expect(dto.dept, isEmpty);
    expect(dto.deptDesc, isEmpty);
  });
}
