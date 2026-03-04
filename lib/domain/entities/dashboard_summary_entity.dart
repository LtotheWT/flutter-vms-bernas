import 'package:equatable/equatable.dart';

import 'dashboard_io_metric_entity.dart';

class DashboardSummaryEntity extends Equatable {
  const DashboardSummaryEntity({
    required this.visitor,
    required this.contractor,
    required this.whitelist,
  });

  final DashboardIoMetricEntity visitor;
  final DashboardIoMetricEntity contractor;
  final DashboardIoMetricEntity whitelist;

  @override
  List<Object?> get props => [visitor, contractor, whitelist];
}
