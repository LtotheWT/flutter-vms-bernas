import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/invitation_create_response_dto.dart';

void main() {
  test('parses successful response with detail fields', () {
    const json = {
      'Status': true,
      'Message': null,
      'Details': {
        'InvitationId': 'IV20260300033',
        'CreatedAt': '2026-03-05T23:29:08.5638287+08:00',
        'GUID': 'c6d92914-3acf-4912-85e8-7bb16976b31f',
        'encryptURL': 'https://example.com/invite/abc',
      },
    };

    final dto = InvitationCreateResponseDto.fromJson(json);
    final entity = dto.toEntity();

    expect(dto.status, isTrue);
    expect(dto.message, isNull);
    expect(dto.invitationId, 'IV20260300033');
    expect(dto.createdAt, '2026-03-05T23:29:08.5638287+08:00');
    expect(dto.guid, 'c6d92914-3acf-4912-85e8-7bb16976b31f');
    expect(dto.encryptUrl, 'https://example.com/invite/abc');
    expect(entity.status, isTrue);
    expect(entity.encryptUrl, 'https://example.com/invite/abc');
  });

  test('parses successful response without details', () {
    const json = {'Status': true, 'Message': null, 'Details': null};

    final dto = InvitationCreateResponseDto.fromJson(json);

    expect(dto.status, isTrue);
    expect(dto.message, isNull);
    expect(dto.invitationId, isNull);
    expect(dto.guid, isNull);
    expect(dto.encryptUrl, isNull);
  });

  test('parses failed response message', () {
    const json = {'Status': false, 'Message': 'invalid payload'};

    final dto = InvitationCreateResponseDto.fromJson(json);

    expect(dto.status, isFalse);
    expect(dto.message, 'invalid payload');
  });
}
