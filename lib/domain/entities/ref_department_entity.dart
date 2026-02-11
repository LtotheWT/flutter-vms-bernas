import 'package:equatable/equatable.dart';

class RefDepartmentEntity extends Equatable {
  const RefDepartmentEntity({required this.code, required this.description});

  final String code;
  final String description;

  @override
  List<Object?> get props => [code, description];
}
