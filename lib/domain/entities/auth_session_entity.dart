import 'package:equatable/equatable.dart';

class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
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

  @override
  List<Object?> get props => [
    username,
    fullname,
    accessToken,
    defaultSite,
    defaultGate,
  ];
}
