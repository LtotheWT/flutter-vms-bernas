import 'package:equatable/equatable.dart';

class DashboardIoMetricEntity extends Equatable {
  const DashboardIoMetricEntity({
    required this.entity,
    required this.totalInRecords,
    required this.totalOutRecords,
    required this.stillInCount,
  });

  final String entity;
  final int totalInRecords;
  final int totalOutRecords;
  final int stillInCount;

  @override
  List<Object?> get props => [
    entity,
    totalInRecords,
    totalOutRecords,
    stillInCount,
  ];
}
