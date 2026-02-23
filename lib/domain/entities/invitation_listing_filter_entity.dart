import 'package:equatable/equatable.dart';

class InvitationListingFilterEntity extends Equatable {
  const InvitationListingFilterEntity({
    this.entity,
    this.site,
    this.department,
    this.visitorType,
    this.statusCode,
    this.invitationId,
    this.visitDateFrom,
    this.visitDateTo,
    this.upcomingOnly = false,
  });

  final String? entity;
  final String? site;
  final String? department;
  final String? visitorType;
  final String? statusCode;
  final String? invitationId;
  final String? visitDateFrom;
  final String? visitDateTo;
  final bool upcomingOnly;

  @override
  List<Object?> get props => [
    entity,
    site,
    department,
    visitorType,
    statusCode,
    invitationId,
    visitDateFrom,
    visitDateTo,
    upcomingOnly,
  ];
}
