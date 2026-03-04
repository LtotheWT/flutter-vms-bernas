import '../../domain/entities/whitelist_search_filter_entity.dart';

class WhitelistSearchRequestDto {
  const WhitelistSearchRequestDto({
    required this.entity,
    required this.currentType,
    required this.vehiclePlate,
    required this.ic,
    required this.status,
  });

  final String entity;
  final String currentType;
  final String vehiclePlate;
  final String ic;
  final String status;

  factory WhitelistSearchRequestDto.fromEntity(
    WhitelistSearchFilterEntity filter,
  ) {
    return WhitelistSearchRequestDto(
      entity: filter.entity.trim(),
      currentType: filter.currentType.trim().toUpperCase(),
      vehiclePlate: filter.vehiclePlate?.trim() ?? '',
      ic: filter.ic?.trim() ?? '',
      status: filter.status?.trim().toUpperCase() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Entity': entity,
      'CURRENT_TYPE': currentType,
      'VehiclePlate': vehiclePlate,
      'IC': ic,
      'STATUS': status,
    };
  }
}
