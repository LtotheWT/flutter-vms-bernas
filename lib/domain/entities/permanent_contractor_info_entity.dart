import 'package:equatable/equatable.dart';

class PermanentContractorInfoEntity extends Equatable {
  const PermanentContractorInfoEntity({
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

  @override
  List<Object?> get props => [
    contractorId,
    contractorName,
    contractorIc,
    hpNo,
    email,
    company,
    validWorkingDateFrom,
    validWorkingDateTo,
  ];
}
