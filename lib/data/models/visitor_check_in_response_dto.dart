import '../../domain/entities/visitor_check_in_result_entity.dart';

class VisitorCheckInResponseDto {
  const VisitorCheckInResponseDto({
    required this.success,
    required this.message,
  });

  final bool success;
  final String? message;

  factory VisitorCheckInResponseDto.fromJson(Map<String, dynamic> json) {
    return VisitorCheckInResponseDto(
      success: json['Success'] == true,
      message: (json['Message'] as String?)?.trim(),
    );
  }

  VisitorCheckInResultEntity toEntity() {
    return VisitorCheckInResultEntity(
      success: success,
      message: message?.trim() ?? '',
    );
  }
}
