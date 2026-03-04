import '../../domain/entities/dashboard_io_metric_entity.dart';

class DashboardIoMetricDto {
  const DashboardIoMetricDto({
    required this.entity,
    required this.totalInRecords,
    required this.totalOutRecords,
    required this.stillInCount,
  });

  final String entity;
  final int totalInRecords;
  final int totalOutRecords;
  final int stillInCount;

  factory DashboardIoMetricDto.fromJson(Map<String, dynamic> json) {
    return DashboardIoMetricDto(
      entity: _asString(json['Entity']),
      totalInRecords: _asInt(json['TotalInRecords']),
      totalOutRecords: _asInt(json['TotalOutRecords']),
      stillInCount: _asInt(json['StillInCount']),
    );
  }

  DashboardIoMetricEntity toEntity() {
    return DashboardIoMetricEntity(
      entity: entity,
      totalInRecords: totalInRecords,
      totalOutRecords: totalOutRecords,
      stillInCount: stillInCount,
    );
  }

  static DashboardIoMetricDto zero(String entity) {
    return DashboardIoMetricDto(
      entity: entity.trim(),
      totalInRecords: 0,
      totalOutRecords: 0,
      stillInCount: 0,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }
}
