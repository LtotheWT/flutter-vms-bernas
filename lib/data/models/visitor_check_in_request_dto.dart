import '../../domain/entities/visitor_check_in_submission_entity.dart';
import '../../domain/entities/visitor_check_in_submission_item_entity.dart';

class VisitorCheckInRequestDto {
  const VisitorCheckInRequestDto({
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

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'entity': entity,
      'site': site,
      'gate': gate,
      'invitationid': invitationId,
      'Visitors': visitors
          .map(
            (item) => {'app_id': item.appId, 'physical_tag': item.physicalTag},
          )
          .toList(growable: false),
    };
  }

  factory VisitorCheckInRequestDto.fromEntity(
    VisitorCheckInSubmissionEntity entity,
  ) {
    return VisitorCheckInRequestDto(
      userId: entity.userId,
      entity: entity.entity,
      site: entity.site,
      gate: entity.gate,
      invitationId: entity.invitationId,
      visitors: entity.visitors,
    );
  }
}
