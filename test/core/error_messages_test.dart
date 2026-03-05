import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/core/error_messages.dart';

void main() {
  group('stripExceptionPrefix', () {
    test('strips Exception prefix and trims whitespace', () {
      expect(
        stripExceptionPrefix('  Exception: Failed to load data.  '),
        'Failed to load data.',
      );
    });

    test('returns original text when prefix is absent', () {
      expect(
        stripExceptionPrefix('Something went wrong'),
        'Something went wrong',
      );
    });
  });

  group('toDisplayErrorMessage', () {
    test('uses normalized message when available', () {
      final message = toDisplayErrorMessage(
        Exception('Backend rejected request.'),
        fallback: 'Fallback message.',
      );

      expect(message, 'Backend rejected request.');
    });

    test('falls back when normalized message is empty', () {
      final message = toDisplayErrorMessage(
        const _EmptyError(),
        fallback: 'Fallback message.',
      );

      expect(message, 'Fallback message.');
    });
  });
}

class _EmptyError {
  const _EmptyError();

  @override
  String toString() => 'Exception:   ';
}
