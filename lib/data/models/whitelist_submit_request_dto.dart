import '../../domain/entities/whitelist_submit_entity.dart';

class WhitelistSubmitRequestDto {
  const WhitelistSubmitRequestDto({
    required this.entity,
    required this.site,
    required this.gate,
    required this.vehiclePlate,
    required this.createdBy,
  });

  final String entity;
  final String site;
  final String gate;
  final String vehiclePlate;
  final String createdBy;

  Map<String, dynamic> toJson() {
    return {
      'Entity': entity,
      'Site': site,
      'Gate': gate,
      'VehiclePlate': vehiclePlate,
      'CreatedBy': createdBy,
    };
  }

  factory WhitelistSubmitRequestDto.fromEntity(WhitelistSubmitEntity entity) {
    return WhitelistSubmitRequestDto(
      entity: entity.entity,
      site: entity.site,
      gate: entity.gate,
      vehiclePlate: entity.vehiclePlate,
      createdBy: entity.createdBy,
    );
  }
}
