import 'package:equatable/equatable.dart';

class PermanentContractorDeletePhotoResultEntity extends Equatable {
  const PermanentContractorDeletePhotoResultEntity({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  List<Object?> get props => [success, message];
}
