import 'package:equatable/equatable.dart';

class WhitelistSearchFilterEntity extends Equatable {
  const WhitelistSearchFilterEntity({
    required this.entity,
    required this.currentType,
    this.vehiclePlate,
    this.ic,
    this.status,
  });

  final String entity;
  final String currentType;
  final String? vehiclePlate;
  final String? ic;
  final String? status;

  @override
  List<Object?> get props => [entity, currentType, vehiclePlate, ic, status];
}
