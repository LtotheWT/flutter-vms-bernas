import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/permanent_contractor_info_dto.dart';

void main() {
  test('parses contractor info payload', () {
    final dto = PermanentContractorInfoDto.fromJson({
      'CONTR_ID': 'C0023',
      'CONTR_NAME': 'Dylan Myer',
      'CONTR_IC': '',
      'HP_NO': '0111111111',
      'EMAIL': 'angypin8978@gmail.com',
      'COMPANY': 'MMG (M) SDN BHD',
      'VALID_WORKING_DATE_FROM': '2026-01-01T00:00:00',
      'VALID_WORKING_DATE_TO': '2026-12-31T00:00:00',
      'HAS_IMAGE': true,
      'IMG_URL': '/test/contractor/C0023/image',
    });

    expect(dto.contractorId, 'C0023');
    expect(dto.contractorName, 'Dylan Myer');
    expect(dto.company, 'MMG (M) SDN BHD');
    expect(dto.validWorkingDateFrom, '2026-01-01T00:00:00');

    final entity = dto.toEntity();
    expect(entity.contractorId, 'C0023');
    expect(entity.hpNo, '0111111111');
  });

  test('null fields map to empty strings', () {
    final dto = PermanentContractorInfoDto.fromJson({
      'CONTR_ID': null,
      'CONTR_NAME': null,
      'CONTR_IC': null,
      'HP_NO': null,
      'EMAIL': null,
      'COMPANY': null,
      'VALID_WORKING_DATE_FROM': null,
      'VALID_WORKING_DATE_TO': null,
    });

    expect(dto.contractorId, isEmpty);
    expect(dto.contractorName, isEmpty);
    expect(dto.email, isEmpty);
  });
}
