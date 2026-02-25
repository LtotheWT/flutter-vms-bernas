import 'visitor_lookup_dto.dart';

class VisitorLookupResponseDto {
  const VisitorLookupResponseDto({
    required this.status,
    required this.message,
    required this.details,
  });

  final bool status;
  final String? message;
  final VisitorLookupDto? details;

  factory VisitorLookupResponseDto.fromJson(Map<String, dynamic> json) {
    final detailsValue = json['Details'];

    return VisitorLookupResponseDto(
      status: json['Status'] == true,
      message: (json['Message'] as String?)?.trim(),
      details: detailsValue is Map<String, dynamic>
          ? VisitorLookupDto.fromJson(detailsValue)
          : (detailsValue is Map
                ? VisitorLookupDto.fromJson(
                    detailsValue.map(
                      (key, value) => MapEntry(key.toString(), value),
                    ),
                  )
                : null),
    );
  }
}
