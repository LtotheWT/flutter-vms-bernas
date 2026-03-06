import 'package:equatable/equatable.dart';

class WhitelistSavePhotoResultEntity extends Equatable {
  const WhitelistSavePhotoResultEntity({
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
