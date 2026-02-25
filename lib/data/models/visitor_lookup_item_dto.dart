import '../../domain/entities/visitor_lookup_item_entity.dart';

class VisitorLookupItemDto {
  const VisitorLookupItemDto({
    required this.name,
    required this.icPassport,
    required this.physicalTag,
    required this.email,
    required this.contactNo,
    required this.company,
    required this.checkInTime,
    required this.checkOutTime,
  });

  final String name;
  final String icPassport;
  final String physicalTag;
  final String email;
  final String contactNo;
  final String company;
  final String checkInTime;
  final String checkOutTime;

  factory VisitorLookupItemDto.fromJson(Map<String, dynamic> json) {
    return VisitorLookupItemDto(
      name: _asString(json['name']),
      icPassport: _asString(json['icPassport']),
      physicalTag: _asString(json['physicalTag']),
      email: _asString(json['email']),
      contactNo: _asString(json['contactNo']),
      company: _asString(json['company']),
      checkInTime: _asString(json['checkInTime']),
      checkOutTime: _asString(json['checkOutTime']),
    );
  }

  VisitorLookupItemEntity toEntity() {
    return VisitorLookupItemEntity(
      name: name,
      icPassport: icPassport,
      physicalTag: physicalTag,
      email: email,
      contactNo: contactNo,
      company: company,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
