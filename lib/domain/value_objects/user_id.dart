import 'package:equatable/equatable.dart';

class UserId extends Equatable {
  const UserId._(this.value);

  final String value;

  factory UserId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('User ID is required.');
    }
    return UserId._(value);
  }

  @override
  List<Object?> get props => [value];
}
