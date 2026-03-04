import 'package:equatable/equatable.dart';

class WhitelistSearchItemEntity extends Equatable {
  const WhitelistSearchItemEntity({
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

  @override
  List<Object?> get props => [
    entity,
    vehiclePlate,
    ic,
    name,
    status,
    createBy,
    createDate,
    updateBy,
    updateDate,
  ];
}
