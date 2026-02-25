import 'package:equatable/equatable.dart';

import 'visitor_lookup_item_entity.dart';

class VisitorLookupEntity extends Equatable {
  const VisitorLookupEntity({
    required this.invitationId,
    required this.entity,
    required this.site,
    required this.siteDesc,
    required this.department,
    required this.departmentDesc,
    required this.purpose,
    required this.company,
    required this.contactNumber,
    required this.visitorType,
    required this.inviteBy,
    required this.workLevel,
    required this.vehiclePlateNumber,
    required this.status,
    required this.visitDateFrom,
    required this.visitDateTo,
    required this.visitTimeFrom,
    required this.visitTimeTo,
    required this.visitors,
  });

  final String invitationId;
  final String entity;
  final String site;
  final String siteDesc;
  final String department;
  final String departmentDesc;
  final String purpose;
  final String company;
  final String contactNumber;
  final String visitorType;
  final String inviteBy;
  final String workLevel;
  final String vehiclePlateNumber;
  final String status;
  final String visitDateFrom;
  final String visitDateTo;
  final String visitTimeFrom;
  final String visitTimeTo;
  final List<VisitorLookupItemEntity> visitors;

  @override
  List<Object?> get props => [
    invitationId,
    entity,
    site,
    siteDesc,
    department,
    departmentDesc,
    purpose,
    company,
    contactNumber,
    visitorType,
    inviteBy,
    workLevel,
    vehiclePlateNumber,
    status,
    visitDateFrom,
    visitDateTo,
    visitTimeFrom,
    visitTimeTo,
    visitors,
  ];
}
