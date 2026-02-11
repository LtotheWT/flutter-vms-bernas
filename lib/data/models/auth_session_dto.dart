import '../../domain/entities/auth_session_entity.dart';

class AuthSessionDto {
  const AuthSessionDto({
    required this.username,
    required this.fullname,
    required this.accessToken,
  });

  final String username;
  final String fullname;
  final String accessToken;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      username: (json['username'] as String?)?.trim() ?? '',
      fullname: (json['fullname'] as String?)?.trim() ?? '',
      accessToken: (json['access_token'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullname': fullname,
      'access_token': accessToken,
    };
  }

  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      username: username,
      fullname: fullname,
      accessToken: accessToken,
    );
  }

  factory AuthSessionDto.fromEntity(AuthSessionEntity entity) {
    return AuthSessionDto(
      username: entity.username,
      fullname: entity.fullname,
      accessToken: entity.accessToken,
    );
  }
}
