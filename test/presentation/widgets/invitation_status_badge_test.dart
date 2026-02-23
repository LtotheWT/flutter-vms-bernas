import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/presentation/widgets/invitation_status_badge.dart';

void main() {
  test('maps known statuses to expected labels', () {
    expect(InvitationStatusPresentation.fromCode('NEW').label, 'New');
    expect(InvitationStatusPresentation.fromCode('APPROVED').label, 'Approved');
    expect(InvitationStatusPresentation.fromCode('REJECTED').label, 'Rejected');
    expect(InvitationStatusPresentation.fromCode('ARRIVED').label, 'Arrived');
    expect(
      InvitationStatusPresentation.fromCode('CHECKED_IN').label,
      'Arrived',
    );
  });

  test('unknown status uses neutral fallback label', () {
    final presentation = InvitationStatusPresentation.fromCode(
      'PENDING_REVIEW',
    );
    expect(presentation.label, 'Pending Review');

    final emptyPresentation = InvitationStatusPresentation.fromCode('   ');
    expect(emptyPresentation.label, 'Unknown');
  });
}
