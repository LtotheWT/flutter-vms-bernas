import '../../domain/entities/invitation_submission_entity.dart';

class InvitationCreateResponseDto {
  const InvitationCreateResponseDto({
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

  factory InvitationCreateResponseDto.fromJson(Map<String, dynamic> json) {
    final statusValue = json['Status'] ?? json['status'];
    final parsedStatus = switch (statusValue) {
      bool value => value,
      num value => value != 0,
      String value => value.toLowerCase() == 'true' || value == '1',
      _ => false,
    };
    final details = _parseDetails(json['Details'] ?? json['details']);

    return InvitationCreateResponseDto(
      status: parsedStatus,
      message: _trimmedOrNull(json['Message'] ?? json['errorMessage']),
      invitationId: _trimmedOrNull(
        details == null
            ? null
            : details['InvitationId'] ?? details['invitationId'],
      ),
      createdAt: _trimmedOrNull(
        details == null ? null : details['CreatedAt'] ?? details['createdAt'],
      ),
      guid: _trimmedOrNull(
        details == null ? null : details['GUID'] ?? details['guid'],
      ),
      encryptUrl: _trimmedOrNull(
        details == null ? null : details['encryptURL'] ?? details['encryptUrl'],
      ),
    );
  }

  InvitationSubmissionEntity toEntity() {
    return InvitationSubmissionEntity(
      status: status,
      message: message,
      invitationId: invitationId,
      createdAt: createdAt,
      guid: guid,
      encryptUrl: encryptUrl,
    );
  }

  static Map<String, dynamic>? _parseDetails(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return null;
  }

  static String? _trimmedOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
