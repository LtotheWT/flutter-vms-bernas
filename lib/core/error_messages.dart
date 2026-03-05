const _exceptionPrefix = 'Exception:';

String stripExceptionPrefix(String value) {
  final text = value.trim();
  if (text.startsWith(_exceptionPrefix)) {
    return text.substring(_exceptionPrefix.length).trim();
  }
  return text;
}

String toDisplayErrorMessage(Object error, {required String fallback}) {
  final message = stripExceptionPrefix(error.toString());
  return message.isEmpty ? fallback : message;
}
