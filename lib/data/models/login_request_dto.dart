class LoginRequestDto {
  const LoginRequestDto({
    required this.ccn,
    required this.userName,
    required this.password,
  });

  final String ccn;
  final String userName;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'CCN': ccn,
      'USER_NAME': userName,
      'PASSWORD': password,
    };
  }
}
