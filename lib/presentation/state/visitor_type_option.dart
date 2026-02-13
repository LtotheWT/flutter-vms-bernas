import 'package:equatable/equatable.dart';

class VisitorTypeOption extends Equatable {
  const VisitorTypeOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}
