import 'package:equatable/equatable.dart';

class InvitationDeleteResultEntity extends Equatable {
  const InvitationDeleteResultEntity({
    required this.status,
    required this.message,
  });

  final bool status;
  final String message;

  @override
  List<Object?> get props => [status, message];
}
