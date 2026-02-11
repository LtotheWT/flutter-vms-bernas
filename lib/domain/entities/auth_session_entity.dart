import 'package:equatable/equatable.dart';

class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
    required this.username,
    required this.fullname,
    required this.accessToken,
  });

  final String username;
  final String fullname;
  final String accessToken;

  @override
  List<Object?> get props => [username, fullname, accessToken];
}
