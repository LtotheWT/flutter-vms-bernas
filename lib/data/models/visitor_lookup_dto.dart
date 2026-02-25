import '../../domain/entities/visitor_lookup_entity.dart';
import 'visitor_lookup_item_dto.dart';

class VisitorLookupDto {
  const VisitorLookupDto({
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
    required this.visitorList,
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
  final List<VisitorLookupItemDto> visitorList;

  factory VisitorLookupDto.fromJson(Map<String, dynamic> json) {
    final visitorListValue = json['visitorList'];
    final visitors = visitorListValue is List
        ? visitorListValue
              .map((item) => VisitorLookupItemDto.fromJson(_asMap(item)))
              .toList(growable: false)
        : const <VisitorLookupItemDto>[];

    return VisitorLookupDto(
      invitationId: _asString(json['invitationId']),
      entity: _asString(json['entity']),
      site: _asString(json['site']),
      siteDesc: _asString(json['siteDesc']),
      department: _asString(json['department']),
      departmentDesc: _asString(json['departmentDesc']),
      purpose: _asString(json['purpose']),
      company: _asString(json['company']),
      contactNumber: _asString(json['contactNumber']),
      visitorType: _asString(json['visitorType']),
      inviteBy: _asString(json['inviteBy']),
      workLevel: _asString(json['workLevel']),
      vehiclePlateNumber: _asString(json['vehiclePlateNumber']),
      status: _asString(json['status']),
      visitDateFrom: _asString(json['visitDateFrom']),
      visitDateTo: _asString(json['visitDateTo']),
      visitTimeFrom: _asString(json['visitTimeFrom']),
      visitTimeTo: _asString(json['visitTimeTo']),
      visitorList: visitors,
    );
  }

  VisitorLookupEntity toEntity() {
    return VisitorLookupEntity(
      invitationId: invitationId,
      entity: entity,
      site: site,
      siteDesc: siteDesc,
      department: department,
      departmentDesc: departmentDesc,
      purpose: purpose,
      company: company,
      contactNumber: contactNumber,
      visitorType: visitorType,
      inviteBy: inviteBy,
      workLevel: workLevel,
      vehiclePlateNumber: vehiclePlateNumber,
      status: status,
      visitDateFrom: visitDateFrom,
      visitDateTo: visitDateTo,
      visitTimeFrom: visitTimeFrom,
      visitTimeTo: visitTimeTo,
      visitors: visitorList
          .map((item) => item.toEntity())
          .toList(growable: false),
    );
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }
}
