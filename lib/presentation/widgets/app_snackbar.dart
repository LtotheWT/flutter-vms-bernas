import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 4),
  bool clearCurrent = true,
}) {
  final messenger = ScaffoldMessenger.of(context);
  if (clearCurrent) {
    messenger.hideCurrentSnackBar();
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      action: action,
      duration: duration,
    ),
  );
}
