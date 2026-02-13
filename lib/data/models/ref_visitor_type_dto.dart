import '../../domain/entities/ref_visitor_type_entity.dart';

class RefVisitorTypeDto {
  const RefVisitorTypeDto({required this.visitorType, required this.typeDesc});

  final String visitorType;
  final String typeDesc;

  factory RefVisitorTypeDto.fromJson(Map<String, dynamic> json) {
    return RefVisitorTypeDto(
      visitorType: (json['visitor_type'] as String? ?? '').trim(),
      typeDesc: (json['type_desc'] as String? ?? '').trim(),
    );
  }

  RefVisitorTypeEntity toEntity() {
    return RefVisitorTypeEntity(
      visitorType: visitorType,
      typeDescription: typeDesc,
    );
  }
}
