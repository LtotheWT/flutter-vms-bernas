import 'package:equatable/equatable.dart';

class EmployeeSubmitResultEntity extends Equatable {
  const EmployeeSubmitResultEntity({
    required this.status,
    required this.message,
    this.eventType = '',
    this.eventDate = '',
    this.photoGuid = '',
  });

  final bool status;
  final String message;
  final String eventType;
  final String eventDate;
  final String photoGuid;

  @override
  List<Object?> get props => [status, message, eventType, eventDate, photoGuid];
}
