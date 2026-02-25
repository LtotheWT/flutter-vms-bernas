import 'package:equatable/equatable.dart';

class VisitorCheckInResultEntity extends Equatable {
  const VisitorCheckInResultEntity({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  List<Object?> get props => [success, message];
}
