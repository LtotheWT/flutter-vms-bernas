import 'package:equatable/equatable.dart';

import 'visitor_check_in_submission_item_entity.dart';

class VisitorCheckInSubmissionEntity extends Equatable {
  const VisitorCheckInSubmissionEntity({
    required this.userId,
    required this.entity,
    required this.site,
    required this.gate,
    required this.invitationId,
    required this.visitors,
  });

  final String userId;
  final String entity;
  final String site;
  final String gate;
  final String invitationId;
  final List<VisitorCheckInSubmissionItemEntity> visitors;

  @override
  List<Object?> get props => [
    userId,
    entity,
    site,
    gate,
    invitationId,
    visitors,
  ];
}
