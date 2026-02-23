class InvitationListingRequestDto {
  const InvitationListingRequestDto({
    required this.department,
    required this.visitorType,
    required this.invitationId,
    required this.status,
    required this.site,
    required this.entity,
    required this.userId,
    required this.visitFrom,
    required this.visitTo,
  });

  final String department;
  final String visitorType;
  final String invitationId;
  final String status;
  final String site;
  final String entity;
  final String userId;
  final String visitFrom;
  final String visitTo;

  Map<String, dynamic> toJson() {
    return {
      'dept': department,
      'visitor_type': visitorType,
      'inviteid': invitationId,
      'status': status,
      'site': site,
      'ccn': entity,
      'userid': userId,
    };
  }
}
