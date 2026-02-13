import '../../domain/entities/ref_personel_entity.dart';

class RefPersonelDto {
  const RefPersonelDto({
    required this.empId,
    required this.empName,
    required this.dept,
    required this.entity,
  });

  final String empId;
  final String empName;
  final String dept;
  final String entity;

  factory RefPersonelDto.fromJson(Map<String, dynamic> json) {
    return RefPersonelDto(
      empId: (json['emp_id'] as String? ?? '').trim(),
      empName: (json['emp_name'] as String? ?? '').trim(),
      dept: (json['dept'] as String? ?? '').trim(),
      entity: (json['entity'] as String? ?? '').trim(),
    );
  }

  RefPersonelEntity toEntity() {
    return RefPersonelEntity(
      employeeId: empId,
      employeeName: empName,
      department: dept,
      entity: entity,
    );
  }
}
