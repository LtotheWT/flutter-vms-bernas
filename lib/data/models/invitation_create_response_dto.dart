import '../../domain/entities/invitation_submission_entity.dart';

class InvitationCreateResponseDto {
  const InvitationCreateResponseDto({required this.status, this.message});

  final bool status;
  final String? message;

  factory InvitationCreateResponseDto.fromJson(Map<String, dynamic> json) {
    final statusValue = json['Status'] ?? json['status'];
    final parsedStatus = switch (statusValue) {
      bool value => value,
      num value => value != 0,
      String value => value.toLowerCase() == 'true' || value == '1',
      _ => false,
    };
    final rawMessage = (json['Message'] ?? json['errorMessage']) as String?;
    final trimmedMessage = rawMessage?.trim();

    return InvitationCreateResponseDto(
      status: parsedStatus,
      message: (trimmedMessage == null || trimmedMessage.isEmpty)
          ? null
          : trimmedMessage,
    );
  }

  InvitationSubmissionEntity toEntity() {
    return InvitationSubmissionEntity(status: status, message: message);
  }
}
