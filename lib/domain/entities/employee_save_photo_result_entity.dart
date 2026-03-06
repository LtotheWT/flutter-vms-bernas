import 'package:equatable/equatable.dart';

class EmployeeSavePhotoResultEntity extends Equatable {
  const EmployeeSavePhotoResultEntity({
    required this.success,
    required this.message,
    required this.photoId,
  });

  final bool success;
  final String message;
  final int? photoId;

  @override
  List<Object?> get props => [success, message, photoId];
}
