import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/permanent_contractor_submit_request_dto.dart';
import 'package:vms_bernas/domain/entities/permanent_contractor_submit_entity.dart';

void main() {
  test('serializes exact payload keys for permanent contractor submit', () {
    final dto = PermanentContractorSubmitRequestDto.fromEntity(
      const PermanentContractorSubmitEntity(
        contractorId: 'C0023',
        site: 'FACTORY1',
        gate: 'F1_A',
        createdBy: 'Ryan',
      ),
    );

    expect(dto.toJson(), {
      'ContractorId': 'C0023',
      'Site': 'FACTORY1',
      'Gate': 'F1_A',
      'CreatedBy': 'Ryan',
    });
  });
}
