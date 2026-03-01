import 'package:intl/intl.dart';

final DateFormat invitationDateTimeDisplayFormat = DateFormat(
  'yyyy-MM-dd hh:mm a',
);

DateTime? tryParseInvitationDateTime(String value) {
  final text = value.trim();
  if (text.isEmpty) {
    return null;
  }

  final normalized = text.replaceFirst(' ', 'T');
  final parsed = DateTime.tryParse(normalized);
  if (parsed != null) {
    return parsed;
  }

  try {
    return invitationDateTimeDisplayFormat.parseStrict(text);
  } on FormatException {
    return null;
  }
}
