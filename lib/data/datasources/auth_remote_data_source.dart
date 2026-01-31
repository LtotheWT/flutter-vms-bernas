class AuthRemoteDataSource {
  Future<void> login({
    required String userId,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (userId.trim().isEmpty || password.trim().isEmpty) {
      throw AuthException('User ID and password are required.');
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
