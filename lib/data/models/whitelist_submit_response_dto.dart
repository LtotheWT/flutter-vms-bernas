import '../../domain/entities/whitelist_submit_result_entity.dart';

class WhitelistSubmitResponseDto {
  const WhitelistSubmitResponseDto({
    required this.status,
    required this.message,
  });

  final bool status;
  final String message;

  factory WhitelistSubmitResponseDto.fromJson(Map<String, dynamic> json) {
    return WhitelistSubmitResponseDto(
      status: json['Status'] == true,
      message: _asString(json['Message']),
    );
  }

  WhitelistSubmitResultEntity toEntity() {
    return WhitelistSubmitResultEntity(status: status, message: message);
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }
}
