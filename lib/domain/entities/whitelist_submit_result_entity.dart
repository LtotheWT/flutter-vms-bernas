import 'package:equatable/equatable.dart';

class WhitelistSubmitResultEntity extends Equatable {
  const WhitelistSubmitResultEntity({
    required this.status,
    required this.message,
  });

  final bool status;
  final String message;

  @override
  List<Object?> get props => [status, message];
}
