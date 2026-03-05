import 'package:equatable/equatable.dart';

class InvitationSubmissionEntity extends Equatable {
  const InvitationSubmissionEntity({
    required this.status,
    this.message,
    this.invitationId,
    this.createdAt,
    this.guid,
    this.encryptUrl,
  });

  final bool status;
  final String? message;
  final String? invitationId;
  final String? createdAt;
  final String? guid;
  final String? encryptUrl;

  @override
  List<Object?> get props => [
    status,
    message,
    invitationId,
    createdAt,
    guid,
    encryptUrl,
  ];
}
