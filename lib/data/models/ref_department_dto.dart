import '../../domain/entities/ref_department_entity.dart';

class RefDepartmentDto {
  const RefDepartmentDto({required this.dept, required this.deptDesc});

  final String dept;
  final String deptDesc;

  factory RefDepartmentDto.fromJson(Map<String, dynamic> json) {
    return RefDepartmentDto(
      dept: (json['dept'] as String? ?? '').trim(),
      deptDesc: (json['dept_desc'] as String? ?? '').trim(),
    );
  }

  RefDepartmentEntity toEntity() {
    return RefDepartmentEntity(code: dept, description: deptDesc);
  }
}
