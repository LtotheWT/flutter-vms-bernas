class UserId {
  const UserId._(this.value);

  final String value;

  factory UserId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('User ID is required.');
    }
    return UserId._(value);
  }
}
