import 'package:equatable/equatable.dart';

class EntityOption extends Equatable {
  const EntityOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}
