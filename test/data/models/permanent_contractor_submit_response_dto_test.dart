import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/permanent_contractor_submit_response_dto.dart';

void main() {
  test('parses wrapped success response', () {
    final dto = PermanentContractorSubmitResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {'Success': true, 'Message': 'Checked-in successfully.'},
    });

    expect(dto.status, isTrue);
    expect(dto.message, 'Checked-in successfully.');
  });

  test('parses flat success response', () {
    final dto = PermanentContractorSubmitResponseDto.fromJson({
      'Success': true,
      'Message': 'Checked-out successfully.',
    });

    expect(dto.status, isTrue);
    expect(dto.message, 'Checked-out successfully.');
  });

  test('prefers wrapped details message on failure', () {
    final dto = PermanentContractorSubmitResponseDto.fromJson({
      'Status': true,
      'Message': null,
      'Details': {'Success': false, 'Message': 'Duplicate IN record'},
    });

    expect(dto.status, isFalse);
    expect(dto.message, 'Duplicate IN record');
  });
}
