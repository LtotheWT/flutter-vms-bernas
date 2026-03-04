import '../../domain/entities/dashboard_summary_entity.dart';
import 'dashboard_io_metric_dto.dart';

class DashboardSummaryResponseDto {
  const DashboardSummaryResponseDto({
    required this.status,
    required this.message,
    required this.visitor,
    required this.contractor,
    required this.whitelist,
  });

  final bool status;
  final String? message;
  final DashboardIoMetricDto visitor;
  final DashboardIoMetricDto contractor;
  final DashboardIoMetricDto whitelist;

  factory DashboardSummaryResponseDto.fromJson(
    Map<String, dynamic> json, {
    required String requestedEntity,
  }) {
    final requested = requestedEntity.trim();
    final detailsValue = json['Details'];
    final details = detailsValue is Map
        ? detailsValue.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};

    return DashboardSummaryResponseDto(
      status: json['Status'] == true,
      message: _asNullableString(json['Message']),
      visitor: _pickMetric(details['VisitorIO'], requested),
      contractor: _pickMetric(details['ContrIO'], requested),
      whitelist: _pickMetric(details['WhitelistIO'], requested),
    );
  }

  DashboardSummaryEntity toEntity() {
    return DashboardSummaryEntity(
      visitor: visitor.toEntity(),
      contractor: contractor.toEntity(),
      whitelist: whitelist.toEntity(),
    );
  }

  static DashboardIoMetricDto _pickMetric(dynamic value, String requested) {
    final normalizedRequested = requested.trim().toUpperCase();
    if (value is List) {
      final items = value
          .whereType<Map>()
          .map(
            (item) => DashboardIoMetricDto.fromJson(
              item.map((key, val) => MapEntry(key.toString(), val)),
            ),
          )
          .toList(growable: false);

      for (final item in items) {
        if (item.entity.trim().toUpperCase() == normalizedRequested &&
            normalizedRequested.isNotEmpty) {
          return item;
        }
      }

      if (items.isNotEmpty) {
        return items.first;
      }
    }

    if (value is Map) {
      return DashboardIoMetricDto.fromJson(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }

    return DashboardIoMetricDto.zero(requested);
  }

  static String? _asNullableString(dynamic value) {
    final text = (value as String? ?? '').trim();
    return text.isEmpty ? null : text;
  }
}
