import 'package:equatable/equatable.dart';

class PermanentContractorSubmitResultEntity extends Equatable {
  const PermanentContractorSubmitResultEntity({
    required this.status,
    required this.message,
  });

  final bool status;
  final String message;

  @override
  List<Object?> get props => [status, message];
}
