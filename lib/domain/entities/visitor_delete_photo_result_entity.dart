import 'package:equatable/equatable.dart';

class VisitorDeletePhotoResultEntity extends Equatable {
  const VisitorDeletePhotoResultEntity({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  List<Object?> get props => [success, message];
}
