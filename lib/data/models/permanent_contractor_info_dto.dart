import '../../domain/entities/permanent_contractor_info_entity.dart';

class PermanentContractorInfoDto {
  const PermanentContractorInfoDto({
    required this.contractorId,
    required this.contractorName,
    required this.contractorIc,
    required this.hpNo,
    required this.email,
    required this.company,
    required this.validWorkingDateFrom,
    required this.validWorkingDateTo,
  });

  final String contractorId;
  final String contractorName;
  final String contractorIc;
  final String hpNo;
  final String email;
  final String company;
  final String validWorkingDateFrom;
  final String validWorkingDateTo;

  factory PermanentContractorInfoDto.fromJson(Map<String, dynamic> json) {
    return PermanentContractorInfoDto(
      contractorId: _asString(json['CONTR_ID']),
      contractorName: _asString(json['CONTR_NAME']),
      contractorIc: _asString(json['CONTR_IC']),
      hpNo: _asString(json['HP_NO']),
      email: _asString(json['EMAIL']),
      company: _asString(json['COMPANY']),
      validWorkingDateFrom: _asString(json['VALID_WORKING_DATE_FROM']),
      validWorkingDateTo: _asString(json['VALID_WORKING_DATE_TO']),
    );
  }

  PermanentContractorInfoEntity toEntity() {
    return PermanentContractorInfoEntity(
      contractorId: contractorId,
      contractorName: contractorName,
      contractorIc: contractorIc,
      hpNo: hpNo,
      email: email,
      company: company,
      validWorkingDateFrom: validWorkingDateFrom,
      validWorkingDateTo: validWorkingDateTo,
    );
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
