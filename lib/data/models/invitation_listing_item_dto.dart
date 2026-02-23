import '../../domain/entities/invitation_list_item_entity.dart';

class InvitationListingItemDto {
  const InvitationListingItemDto({
    required this.entity,
    required this.site,
    required this.invitationId,
    required this.department,
    required this.inviteBy,
    required this.createBy,
    required this.visitorType,
    required this.company,
    required this.companyVisitorName,
    required this.vehiclePlate,
    required this.status,
    required this.purpose,
    required this.visitDateFrom,
    required this.visitTimeFrom,
    required this.visitDateTo,
    required this.visitTimeTo,
    required this.createDate,
    required this.updateDate,
    required this.updateBy,
  });

  final String entity;
  final String site;
  final String invitationId;
  final String department;
  final String inviteBy;
  final String createBy;
  final String visitorType;
  final String company;
  final String companyVisitorName;
  final String vehiclePlate;
  final String status;
  final String purpose;
  final String visitDateFrom;
  final String visitTimeFrom;
  final String visitDateTo;
  final String visitTimeTo;
  final String createDate;
  final String updateDate;
  final String updateBy;

  factory InvitationListingItemDto.fromJson(Map<String, dynamic> json) {
    return InvitationListingItemDto(
      entity: _asString(json['Entity']),
      site: _asString(json['Site']),
      invitationId: _asString(json['InvitationId']),
      department: _asString(json['Department']),
      inviteBy: _asString(json['InviteBy']),
      createBy: _asString(json['CreateBy']),
      visitorType: _asString(json['VisitorType']),
      company: _asString(json['Company']),
      companyVisitorName: _asString(json['CompanyVisitorName']),
      vehiclePlate: _asString(json['VehiclePlate']),
      status: _asString(json['Status']),
      purpose: _asString(json['Purpose']),
      visitDateFrom: _asString(json['VisitDateFrom']),
      visitTimeFrom: _asString(json['VisitTimeFrom']),
      visitDateTo: _asString(json['VisitDateTo']),
      visitTimeTo: _asString(json['VisitTimeTo']),
      createDate: _asString(json['CreateDate']),
      updateDate: _asString(json['UpdateDate']),
      updateBy: _asString(json['UpdateBy']),
    );
  }

  InvitationListItemEntity toEntity() {
    final effectiveCompany = company.trim().isNotEmpty
        ? company.trim()
        : companyVisitorName.trim();

    return InvitationListItemEntity(
      invitationId: invitationId,
      entity: entity,
      site: site,
      department: department,
      inviteBy: inviteBy,
      createdBy: createBy,
      visitorType: visitorType,
      company: effectiveCompany,
      vehiclePlateNumber: vehiclePlate,
      statusCode: status,
      purpose: purpose,
      visitDateFrom: visitDateFrom,
      visitTimeFrom: visitTimeFrom,
      visitDateTo: visitDateTo,
      visitTimeTo: visitTimeTo,
      createDate: createDate,
      updateDate: updateDate,
      updateBy: updateBy,
    );
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
