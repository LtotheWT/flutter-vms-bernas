import '../../domain/entities/whitelist_detail_entity.dart';

class WhitelistDetailResponseDto {
  const WhitelistDetailResponseDto({
    required this.status,
    required this.message,
    required this.details,
  });

  final bool status;
  final String? message;
  final WhitelistDetailDto? details;

  factory WhitelistDetailResponseDto.fromJson(Map<String, dynamic> json) {
    final detailsValue = json['Details'];
    return WhitelistDetailResponseDto(
      status: json['Status'] == true,
      message: _asNullableString(json['Message']),
      details: detailsValue is Map
          ? WhitelistDetailDto.fromJson(
              detailsValue.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
    );
  }

  static String? _asNullableString(Object? value) {
    final text = (value as String? ?? '').trim();
    return text.isEmpty ? null : text;
  }
}

class WhitelistDetailDto {
  const WhitelistDetailDto({
    required this.entity,
    required this.vehiclePlate,
    required this.ic,
    required this.name,
    required this.status,
    required this.createBy,
    required this.createDate,
    required this.updateBy,
    required this.updateDate,
  });

  final String entity;
  final String vehiclePlate;
  final String ic;
  final String name;
  final String status;
  final String createBy;
  final String createDate;
  final String updateBy;
  final String updateDate;

  factory WhitelistDetailDto.fromJson(Map<String, dynamic> json) {
    return WhitelistDetailDto(
      entity: _asString(json['ENTITY']),
      vehiclePlate: _asString(json['WL_VEHICLE_PLATE']),
      ic: _asString(json['WL_IC']),
      name: _asString(json['WL_NAME']),
      status: _normalizeStatus(_asString(json['STATUS'])),
      createBy: _asString(json['CREATE_BY']),
      createDate: _asString(json['CREATE_DATE']),
      updateBy: _asString(json['UPDATE_BY']),
      updateDate: _asString(json['UPDATE_DATE']),
    );
  }

  WhitelistDetailEntity toEntity() {
    return WhitelistDetailEntity(
      entity: entity,
      vehiclePlate: vehiclePlate,
      ic: ic,
      name: name,
      status: status,
      createBy: createBy,
      createDate: createDate,
      updateBy: updateBy,
      updateDate: updateDate,
    );
  }

  static String _normalizeStatus(String value) {
    final upper = value.trim().toUpperCase();
    switch (upper) {
      case 'A':
      case 'ACTIVE':
        return 'ACTIVE';
      case 'I':
      case 'INACTIVE':
        return 'INACTIVE';
      default:
        return upper;
    }
  }

  static String _asString(Object? value) => (value as String? ?? '').trim();
}
