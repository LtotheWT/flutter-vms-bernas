import 'dart:developer';

import '../../domain/entities/visitor_check_in_result_entity.dart';

class VisitorCheckInResponseDto {
  const VisitorCheckInResponseDto({
    required this.status,
    required this.message,
  });

  final bool status;
  final String? message;

  factory VisitorCheckInResponseDto.fromJson(Map<String, dynamic> json) {
    return VisitorCheckInResponseDto(
      status: json['Status'] == true,
      message: (json['Message'] as String?)?.trim(),
    );
  }

  VisitorCheckInResultEntity toEntity() {
    return VisitorCheckInResultEntity(
      status: status,
      message: message?.trim() ?? '',
    );
  }
}
