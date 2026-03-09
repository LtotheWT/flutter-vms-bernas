import '../../domain/entities/invitation_delete_result_entity.dart';

class InvitationDeleteResponseDto {
  const InvitationDeleteResponseDto({
    required this.status,
    required this.message,
  });

  final bool status;
  final String? message;

  factory InvitationDeleteResponseDto.fromJson(Map<String, dynamic> json) {
    return InvitationDeleteResponseDto(
      status: _asBool(json['Status'] ?? json['status']),
      message: _asStringOrNull(json['Message'] ?? json['message']),
    );
  }

  InvitationDeleteResultEntity toEntity() {
    return InvitationDeleteResultEntity(
      status: status,
      message: message?.trim() ?? '',
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String? _asStringOrNull(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
