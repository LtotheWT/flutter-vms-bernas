import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/presentation/state/async_option_helpers.dart';

void main() {
  test('extractOptions returns data list when async has data', () {
    const async = AsyncValue<List<int>>.data(<int>[1, 2, 3]);

    final result = extractOptions<int>(async);

    expect(result, <int>[1, 2, 3]);
  });

  test('extractOptions returns empty list when async is loading', () {
    const async = AsyncValue<List<int>>.loading();

    final result = extractOptions<int>(async);

    expect(result, isEmpty);
  });

  test('extractErrorText maps error text and returns null for non-error', () {
    final errorAsync = AsyncValue<List<int>>.error(
      Exception('boom'),
      StackTrace.current,
    );
    const dataAsync = AsyncValue<List<int>>.data(<int>[1]);

    final errorText = extractErrorText(
      errorAsync,
      fallback: 'fallback',
      errorToText: (error, fallback) => '$fallback:${error.toString()}',
    );
    final dataText = extractErrorText(
      dataAsync,
      fallback: 'fallback',
      errorToText: (error, fallback) => '$fallback:${error.toString()}',
    );

    expect(errorText, contains('fallback:'));
    expect(dataText, isNull);
  });

  test(
    'findDisplayLabel returns label when match exists, fallback otherwise',
    () {
      const options = <({String value, String label})>[
        (value: 'A', label: 'Alpha'),
        (value: 'B', label: 'Beta'),
      ];

      final matched = findDisplayLabel<({String value, String label})>(
        options: options,
        selectedCode: 'B',
        valueOf: (option) => option.value,
        labelOf: (option) => option.label,
      );
      final fallback = findDisplayLabel<({String value, String label})>(
        options: options,
        selectedCode: 'Z',
        valueOf: (option) => option.value,
        labelOf: (option) => option.label,
      );

      expect(matched, 'Beta');
      expect(fallback, 'Z');
    },
  );

  test('pickState resolves state for no parent, loading, error and ready', () {
    const loadingAsync = AsyncValue<List<int>>.loading();
    final errorAsync = AsyncValue<List<int>>.error(
      Exception('e'),
      StackTrace.current,
    );
    const readyAsync = AsyncValue<List<int>>.data(<int>[1]);

    final noParent = pickState(hasParent: false, asyncValue: readyAsync);
    final loading = pickState(hasParent: true, asyncValue: loadingAsync);
    final error = pickState(hasParent: true, asyncValue: errorAsync);
    final ready = pickState(hasParent: true, asyncValue: readyAsync);

    expect(noParent.enabled, isFalse);
    expect(noParent.canPick, isFalse);
    expect(noParent.canRetry, isFalse);

    expect(loading.enabled, isFalse);
    expect(loading.canPick, isFalse);
    expect(loading.canRetry, isFalse);

    expect(error.enabled, isTrue);
    expect(error.canPick, isFalse);
    expect(error.canRetry, isTrue);

    expect(ready.enabled, isTrue);
    expect(ready.canPick, isTrue);
    expect(ready.canRetry, isFalse);
  });

  test('shouldClearStaleSelection only true when selected value is absent', () {
    const options = <({String value})>[(value: 'A'), (value: 'B')];

    final whenNull = shouldClearStaleSelection<({String value})>(
      selectedValue: null,
      options: options,
      valueOf: (option) => option.value,
    );
    final whenPresent = shouldClearStaleSelection<({String value})>(
      selectedValue: 'B',
      options: options,
      valueOf: (option) => option.value,
    );
    final whenAbsent = shouldClearStaleSelection<({String value})>(
      selectedValue: 'Z',
      options: options,
      valueOf: (option) => option.value,
    );

    expect(whenNull, isFalse);
    expect(whenPresent, isFalse);
    expect(whenAbsent, isTrue);
  });
}
