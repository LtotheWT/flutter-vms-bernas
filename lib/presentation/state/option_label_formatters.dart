String labelOrBlank(String raw) {
  final text = raw.trim();
  return text.isEmpty ? '(Blank)' : text;
}

String siteLabel({required String value, required String label}) {
  final text = label.trim();
  if (text.isNotEmpty) {
    return text;
  }
  return labelOrBlank(value);
}

String visitorTypeLabel({required String value, required String label}) {
  final text = label.trim();
  if (text.isNotEmpty) {
    return text;
  }
  return labelOrBlank(value);
}

String hostLabel({required String employeeId, required String employeeName}) {
  final id = employeeId.trim();
  final name = employeeName.trim();
  if (name.isNotEmpty && id.isNotEmpty) {
    return '$name ($id)';
  }
  if (name.isNotEmpty) {
    return name;
  }
  return labelOrBlank(id);
}
