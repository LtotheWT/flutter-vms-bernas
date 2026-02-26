import 'package:equatable/equatable.dart';

class VisitorCheckInResultEntity extends Equatable {
  const VisitorCheckInResultEntity({
    required this.status,
    required this.message,
  });

  final bool status;
  final String message;

  @override
  List<Object?> get props => [status, message];
}
