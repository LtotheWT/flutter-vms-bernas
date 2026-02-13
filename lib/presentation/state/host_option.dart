import 'package:equatable/equatable.dart';

class HostOption extends Equatable {
  const HostOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}
