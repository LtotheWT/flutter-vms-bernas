import '../../domain/entities/ref_location_entity.dart';

class RefLocationDto {
  const RefLocationDto({required this.site, required this.siteDesc});

  final String site;
  final String siteDesc;

  factory RefLocationDto.fromJson(Map<String, dynamic> json) {
    return RefLocationDto(
      site: (json['site'] as String? ?? '').trim(),
      siteDesc: (json['site_desc'] as String? ?? '').trim(),
    );
  }

  RefLocationEntity toEntity() {
    return RefLocationEntity(site: site, siteDescription: siteDesc);
  }
}
