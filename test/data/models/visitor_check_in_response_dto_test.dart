import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/visitor_check_in_response_dto.dart';

void main() {
  test('parses success response', () {
    const json = {'Success': true, 'Message': 'Checked-in successfully.'};
    final dto = VisitorCheckInResponseDto.fromJson(json);
    final entity = dto.toEntity();

    expect(dto.status, isTrue);
    expect(dto.message, 'Checked-in successfully.');
    expect(entity.status, isTrue);
    expect(entity.message, 'Checked-in successfully.');
  });

  test('maps null message to empty message in entity', () {
    const json = {'Success': false, 'Message': null};
    final dto = VisitorCheckInResponseDto.fromJson(json);
    final entity = dto.toEntity();

    expect(dto.status, isFalse);
    expect(entity.message, isEmpty);
  });
}
