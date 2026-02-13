import 'package:equatable/equatable.dart';

class RefVisitorTypeEntity extends Equatable {
  const RefVisitorTypeEntity({
    required this.visitorType,
    required this.typeDescription,
  });

  final String visitorType;
  final String typeDescription;

  @override
  List<Object?> get props => [visitorType, typeDescription];
}
