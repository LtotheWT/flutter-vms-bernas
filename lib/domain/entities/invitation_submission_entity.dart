import 'package:equatable/equatable.dart';

class InvitationSubmissionEntity extends Equatable {
  const InvitationSubmissionEntity({required this.status, this.message});

  final bool status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}
