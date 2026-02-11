import 'package:equatable/equatable.dart';

class RefEntityEntity extends Equatable {
  const RefEntityEntity({required this.code, required this.name});

  final String code;
  final String name;

  @override
  List<Object?> get props => [code, name];
}
