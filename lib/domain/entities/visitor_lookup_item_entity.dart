import 'package:equatable/equatable.dart';

class VisitorLookupItemEntity extends Equatable {
  const VisitorLookupItemEntity({
    required this.name,
    required this.icPassport,
    required this.physicalTag,
    required this.email,
    required this.contactNo,
    required this.company,
    required this.checkInTime,
    required this.checkOutTime,
  });

  final String name;
  final String icPassport;
  final String physicalTag;
  final String email;
  final String contactNo;
  final String company;
  final String checkInTime;
  final String checkOutTime;

  @override
  List<Object?> get props => [
    name,
    icPassport,
    physicalTag,
    email,
    contactNo,
    company,
    checkInTime,
    checkOutTime,
  ];
}
