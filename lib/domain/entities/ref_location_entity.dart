import 'package:equatable/equatable.dart';

class RefLocationEntity extends Equatable {
  const RefLocationEntity({required this.site, required this.siteDescription});

  final String site;
  final String siteDescription;

  @override
  List<Object?> get props => [site, siteDescription];
}
