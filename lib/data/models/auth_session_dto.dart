import '../../domain/entities/auth_session_entity.dart';

class AuthSessionDto {
  const AuthSessionDto({
    required this.username,
    required this.fullname,
    required this.accessToken,
    required this.defaultSite,
    required this.defaultGate,
  });

  final String username;
  final String fullname;
  final String accessToken;
  final String defaultSite;
  final String defaultGate;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      username: (json['username'] as String?)?.trim() ?? '',
      fullname: (json['fullname'] as String?)?.trim() ?? '',
      accessToken: (json['access_token'] as String?)?.trim() ?? '',
      defaultSite: (json['default_site'] as String?)?.trim() ?? '',
      defaultGate: (json['default_gate'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullname': fullname,
      'access_token': accessToken,
      'default_site': defaultSite,
      'default_gate': defaultGate,
    };
  }

  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      username: username,
      fullname: fullname,
      accessToken: accessToken,
      defaultSite: defaultSite,
      defaultGate: defaultGate,
    );
  }

  factory AuthSessionDto.fromEntity(AuthSessionEntity entity) {
    return AuthSessionDto(
      username: entity.username,
      fullname: entity.fullname,
      accessToken: entity.accessToken,
      defaultSite: entity.defaultSite,
      defaultGate: entity.defaultGate,
    );
  }
}
