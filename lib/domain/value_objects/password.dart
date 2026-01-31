class Password {
  const Password._(this.value);

  final String value;

  factory Password(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Password is required.');
    }
    return Password._(value);
  }
}
