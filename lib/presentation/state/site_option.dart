import 'package:equatable/equatable.dart';

class SiteOption extends Equatable {
  const SiteOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}
