import 'package:equatable/equatable.dart';

class EmployeeInfoEntity extends Equatable {
  const EmployeeInfoEntity({
    required this.employeeId,
    required this.employeeName,
    required this.site,
    required this.department,
    required this.unit,
    required this.vehicleType,
    required this.handphoneNo,
    required this.telNoExtension,
    required this.effectiveWorkingDate,
    required this.lastWorkingDate,
  });

  final String employeeId;
  final String employeeName;
  final String site;
  final String department;
  final String unit;
  final String vehicleType;
  final String handphoneNo;
  final String telNoExtension;
  final String effectiveWorkingDate;
  final String lastWorkingDate;

  @override
  List<Object?> get props => [
    employeeId,
    employeeName,
    site,
    department,
    unit,
    vehicleType,
    handphoneNo,
    telNoExtension,
    effectiveWorkingDate,
    lastWorkingDate,
  ];
}
