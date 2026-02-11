import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/login_response_dto.dart';

void main() {
  test('parses success payload with auth details', () {
    const json = {
      'Status': true,
      'ErrorMessage': null,
      'Details': {
        'username': 'Ryan',
        'fullname': 'Ryan',
        'access_token': 'token123',
      },
    };

    final dto = LoginResponseDto.fromJson(json);

    expect(dto.status, isTrue);
    expect(dto.errorMessage, isNull);
    expect(dto.details, isNotNull);
    expect(dto.details?.username, 'Ryan');
    expect(dto.details?.accessToken, 'token123');
  });

  test('parses failure payload and keeps backend error message', () {
    const json = {
      'Status': false,
      'ErrorMessage': 'Invalid user, user was not found!',
      'Details': null,
    };

    final dto = LoginResponseDto.fromJson(json);

    expect(dto.status, isFalse);
    expect(dto.errorMessage, 'Invalid user, user was not found!');
    expect(dto.details, isNull);
  });
}
