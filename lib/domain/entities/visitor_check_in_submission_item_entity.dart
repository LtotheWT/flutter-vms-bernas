import 'package:equatable/equatable.dart';

class VisitorCheckInSubmissionItemEntity extends Equatable {
  const VisitorCheckInSubmissionItemEntity({
    required this.appId,
    required this.physicalTag,
  });

  final String appId;
  final String physicalTag;

  @override
  List<Object?> get props => [appId, physicalTag];
}
