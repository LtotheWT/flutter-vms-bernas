import 'package:equatable/equatable.dart';

class DepartmentOption extends Equatable {
  const DepartmentOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}
