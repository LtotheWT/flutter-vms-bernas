import 'package:equatable/equatable.dart';

class InvitationListItemEntity extends Equatable {
  const InvitationListItemEntity({
    required this.invitationId,
    required this.entity,
    required this.site,
    required this.department,
    required this.inviteBy,
    required this.createdBy,
    required this.visitorType,
    required this.company,
    required this.vehiclePlateNumber,
    required this.statusCode,
    required this.purpose,
    required this.visitDateFrom,
    required this.visitTimeFrom,
    required this.visitDateTo,
    required this.visitTimeTo,
    required this.createDate,
    required this.updateDate,
    required this.updateBy,
  });

  final String invitationId;
  final String entity;
  final String site;
  final String department;
  final String inviteBy;
  final String createdBy;
  final String visitorType;
  final String company;
  final String vehiclePlateNumber;
  final String statusCode;
  final String purpose;
  final String visitDateFrom;
  final String visitTimeFrom;
  final String visitDateTo;
  final String visitTimeTo;
  final String createDate;
  final String updateDate;
  final String updateBy;

  @override
  List<Object?> get props => [
    invitationId,
    entity,
    site,
    department,
    inviteBy,
    createdBy,
    visitorType,
    company,
    vehiclePlateNumber,
    statusCode,
    purpose,
    visitDateFrom,
    visitTimeFrom,
    visitDateTo,
    visitTimeTo,
    createDate,
    updateDate,
    updateBy,
  ];
}
