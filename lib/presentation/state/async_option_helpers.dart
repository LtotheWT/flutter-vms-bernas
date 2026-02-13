import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ErrorTextMapper = String Function(Object error, String fallback);

class AsyncPickState {
  const AsyncPickState({
    required this.canRetry,
    required this.canPick,
    required this.enabled,
  });

  final bool canRetry;
  final bool canPick;
  final bool enabled;
}

List<T> extractOptions<T>(AsyncValue<List<T>> asyncValue) {
  return asyncValue.maybeWhen(data: (data) => data, orElse: () => <T>[]);
}

String? extractErrorText(
  AsyncValue<dynamic> asyncValue, {
  required String fallback,
  required ErrorTextMapper errorToText,
}) {
  return asyncValue.whenOrNull(
    error: (error, _) => errorToText(error, fallback),
  );
}

String? findDisplayLabel<T>({
  required List<T> options,
  required String? selectedCode,
  required String Function(T option) valueOf,
  required String Function(T option) labelOf,
}) {
  if (selectedCode == null) return null;
  for (final option in options) {
    if (valueOf(option) == selectedCode) {
      return labelOf(option);
    }
  }
  return selectedCode;
}

AsyncPickState pickState({
  required bool hasParent,
  required AsyncValue<dynamic> asyncValue,
}) {
  final isLoading = asyncValue.isLoading;
  final hasError = asyncValue.hasError;

  return AsyncPickState(
    canRetry: hasParent && hasError,
    canPick: hasParent && !isLoading && !hasError,
    enabled: hasParent && !isLoading,
  );
}

bool shouldClearStaleSelection<T>({
  required String? selectedValue,
  required List<T> options,
  required String Function(T option) valueOf,
}) {
  if (selectedValue == null) return false;
  return !options.any((option) => valueOf(option) == selectedValue);
}
