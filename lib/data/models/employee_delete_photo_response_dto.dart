import '../../domain/entities/employee_delete_photo_result_entity.dart';

class EmployeeDeletePhotoResponseDto {
  const EmployeeDeletePhotoResponseDto({
    required this.status,
    required this.message,
  });

  final bool status;
  final String? message;

  factory EmployeeDeletePhotoResponseDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDeletePhotoResponseDto(
      status: _asBool(json['status'] ?? json['Status']),
      message: _asStringOrNull(json['message'] ?? json['Message']),
    );
  }

  EmployeeDeletePhotoResultEntity toEntity() {
    return EmployeeDeletePhotoResultEntity(
      success: status,
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
