import 'package:equatable/equatable.dart';

class EmployeeDeletePhotoResultEntity extends Equatable {
  const EmployeeDeletePhotoResultEntity({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  List<Object?> get props => [success, message];
}
