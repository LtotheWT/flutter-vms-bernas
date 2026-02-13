import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/invitation_create_response_dto.dart';

void main() {
  test('parses successful response', () {
    const json = {'Status': true, 'Message': null};

    final dto = InvitationCreateResponseDto.fromJson(json);

    expect(dto.status, isTrue);
    expect(dto.message, isNull);
    expect(dto.toEntity().status, isTrue);
  });

  test('parses failed response message', () {
    const json = {'Status': false, 'Message': 'invalid payload'};

    final dto = InvitationCreateResponseDto.fromJson(json);

    expect(dto.status, isFalse);
    expect(dto.message, 'invalid payload');
  });
}
