import 'package:equatable/equatable.dart';

class WhitelistSubmitEntity extends Equatable {
  const WhitelistSubmitEntity({
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

  @override
  List<Object?> get props => [entity, site, gate, vehiclePlate, createdBy];
}
