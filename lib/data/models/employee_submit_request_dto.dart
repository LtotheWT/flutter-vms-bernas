import '../../domain/entities/employee_submit_entity.dart';

class EmployeeSubmitRequestDto {
  const EmployeeSubmitRequestDto({
    required this.employeeId,
    required this.site,
    required this.gate,
    required this.createdBy,
  });

  final String employeeId;
  final String site;
  final String gate;
  final String createdBy;

  Map<String, dynamic> toJson() {
    return {
      'EmployeeId': employeeId,
      'Site': site,
      'Gate': gate,
      'CreatedBy': createdBy,
    };
  }

  factory EmployeeSubmitRequestDto.fromEntity(EmployeeSubmitEntity entity) {
    return EmployeeSubmitRequestDto(
      employeeId: entity.employeeId,
      site: entity.site,
      gate: entity.gate,
      createdBy: entity.createdBy,
    );
  }
}
