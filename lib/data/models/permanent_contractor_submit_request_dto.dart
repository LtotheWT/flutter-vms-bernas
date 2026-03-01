import '../../domain/entities/permanent_contractor_submit_entity.dart';

class PermanentContractorSubmitRequestDto {
  const PermanentContractorSubmitRequestDto({
    required this.contractorId,
    required this.site,
    required this.gate,
    required this.createdBy,
  });

  final String contractorId;
  final String site;
  final String gate;
  final String createdBy;

  Map<String, dynamic> toJson() {
    return {
      'ContractorId': contractorId,
      'Site': site,
      'Gate': gate,
      'CreatedBy': createdBy,
    };
  }

  factory PermanentContractorSubmitRequestDto.fromEntity(
    PermanentContractorSubmitEntity entity,
  ) {
    return PermanentContractorSubmitRequestDto(
      contractorId: entity.contractorId,
      site: entity.site,
      gate: entity.gate,
      createdBy: entity.createdBy,
    );
  }
}
