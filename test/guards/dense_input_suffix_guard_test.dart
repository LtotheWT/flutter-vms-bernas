import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dense input suffixes do not use IconButton in key check-in pages', () {
    const files = <String>[
      'lib/presentation/pages/visitor_check_in_page.dart',
      'lib/presentation/pages/permanent_contractor_check_page.dart',
    ];

    final violations = <String>[];
    final pattern = RegExp(r'suffixIcon\s*:\s*IconButton\s*\(');

    for (final file in files) {
      final content = File(file).readAsStringSync();
      if (pattern.hasMatch(content)) {
        violations.add(file);
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Use CompactSuffixTapIcon/GestureDetector for dense input suffix actions.',
    );
  });
}
