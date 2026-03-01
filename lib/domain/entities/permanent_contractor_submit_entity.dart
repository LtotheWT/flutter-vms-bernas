import 'package:equatable/equatable.dart';

class PermanentContractorSubmitEntity extends Equatable {
  const PermanentContractorSubmitEntity({
    required this.contractorId,
    required this.site,
    required this.gate,
    required this.createdBy,
  });

  final String contractorId;
  final String site;
  final String gate;
  final String createdBy;

  @override
  List<Object?> get props => [contractorId, site, gate, createdBy];
}
