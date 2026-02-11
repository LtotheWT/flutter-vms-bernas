import '../../domain/entities/ref_entity_entity.dart';

class RefEntityDto {
  const RefEntityDto({required this.entity, required this.entityName});

  final String entity;
  final String entityName;

  factory RefEntityDto.fromJson(Map<String, dynamic> json) {
    return RefEntityDto(
      entity: (json['entity'] as String? ?? '').trim(),
      entityName: (json['entity_name'] as String? ?? '').trim(),
    );
  }

  RefEntityEntity toEntity() {
    return RefEntityEntity(code: entity, name: entityName);
  }
}
