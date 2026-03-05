import 'package:equatable/equatable.dart';

class EmployeeSubmitEntity extends Equatable {
  const EmployeeSubmitEntity({
    required this.employeeId,
    required this.site,
    required this.gate,
    required this.createdBy,
  });

  final String employeeId;
  final String site;
  final String gate;
  final String createdBy;

  @override
  List<Object?> get props => [employeeId, site, gate, createdBy];
}
