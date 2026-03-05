import '../../domain/entities/employee_submit_result_entity.dart';

class EmployeeSubmitResponseDto {
  const EmployeeSubmitResponseDto({
    required this.status,
    required this.message,
    required this.eventType,
    required this.eventDate,
    required this.photoGuid,
  });

  final bool status;
  final String message;
  final String eventType;
  final String eventDate;
  final String photoGuid;

  factory EmployeeSubmitResponseDto.fromJson(Map<String, dynamic> json) {
    final detailsValue = json['Details'];
    final details = detailsValue is Map
        ? detailsValue.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    return EmployeeSubmitResponseDto(
      status: json['Status'] == true,
      message: _asString(json['Message']),
      eventType: _asString(details['EventType']),
      eventDate: _asString(details['EventDate']),
      photoGuid: _asString(details['PhotoGuid']),
    );
  }

  EmployeeSubmitResultEntity toEntity() {
    return EmployeeSubmitResultEntity(
      status: status,
      message: message,
      eventType: eventType,
      eventDate: eventDate,
      photoGuid: photoGuid,
    );
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }
}
