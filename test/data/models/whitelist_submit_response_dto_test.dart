import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/whitelist_submit_response_dto.dart';

void main() {
  test('parses status and message', () {
    final dto = WhitelistSubmitResponseDto.fromJson({
      'Status': true,
      'Message': 'Whitelist checked IN successfully.',
      'Details': null,
    });

    expect(dto.status, isTrue);
    expect(dto.message, 'Whitelist checked IN successfully.');
  });

  test('handles null message as empty string', () {
    final dto = WhitelistSubmitResponseDto.fromJson({
      'Status': false,
      'Message': null,
      'Details': null,
    });

    expect(dto.status, isFalse);
    expect(dto.message, '');
  });
}
