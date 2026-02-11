import 'package:equatable/equatable.dart';

class Password extends Equatable {
  const Password._(this.value);

  final String value;

  factory Password(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Password is required.');
    }
    return Password._(value);
  }

  @override
  List<Object?> get props => [value];
}
