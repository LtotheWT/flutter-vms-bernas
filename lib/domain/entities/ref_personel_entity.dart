import 'package:equatable/equatable.dart';

class RefPersonelEntity extends Equatable {
  const RefPersonelEntity({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.entity,
  });

  final String employeeId;
  final String employeeName;
  final String department;
  final String entity;

  @override
  List<Object?> get props => [employeeId, employeeName, department, entity];
}
