class InvitationCreateRequestDto {
  const InvitationCreateRequestDto({
    required this.ccn,
    required this.userId,
    required this.site,
    required this.dept,
    required this.employee,
    required this.visitorType,
    required this.visitorName,
    required this.purpose,
    required this.invitePurpose,
    required this.email,
    required this.visitFrom,
    required this.visitTo,
  });

  final String ccn;
  final String userId;
  final String site;
  final String dept;
  final String employee;
  final String visitorType;
  final String visitorName;
  final String purpose;
  final String invitePurpose;
  final String email;
  final String visitFrom;
  final String visitTo;

  Map<String, dynamic> toJson() {
    return {
      'ccn': ccn,
      'userid': userId,
      'site': site,
      'dept': dept,
      'employee': employee,
      'visitor_type': visitorType,
      'visitor_name': visitorName,
      'purpose': purpose,
      'invite_purpose': invitePurpose,
      'email': email,
      'visit_from': visitFrom,
      'visit_to': visitTo,
    };
  }
}
