import 'package:equatable/equatable.dart';

class WhitelistDeletePhotoResultEntity extends Equatable {
  const WhitelistDeletePhotoResultEntity({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  List<Object?> get props => [success, message];
}
