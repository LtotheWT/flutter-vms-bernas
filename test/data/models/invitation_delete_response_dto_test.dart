import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/invitation_delete_response_dto.dart';

void main() {
  test('InvitationDeleteResponseDto parses wrapper response', () {
    final dto = InvitationDeleteResponseDto.fromJson({
      'Status': true,
      'Message': 'Visitor deleted successfully',
      'Details': null,
    });

    expect(dto.status, isTrue);
    expect(dto.message, 'Visitor deleted successfully');
    expect(dto.toEntity().status, isTrue);
  });
}
