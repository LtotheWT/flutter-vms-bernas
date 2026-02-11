import 'auth_session_dto.dart';

class LoginResponseDto {
  const LoginResponseDto({
    required this.status,
    required this.errorMessage,
    required this.details,
  });

  final bool status;
  final String? errorMessage;
  final AuthSessionDto? details;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final detailsValue = json['Details'];

    return LoginResponseDto(
      status: json['Status'] == true,
      errorMessage: (json['ErrorMessage'] as String?)?.trim(),
      details: detailsValue is Map<String, dynamic>
          ? AuthSessionDto.fromJson(detailsValue)
          : null,
    );
  }
}
