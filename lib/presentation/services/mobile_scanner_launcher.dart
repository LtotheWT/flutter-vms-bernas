import 'package:flutter/material.dart';

import '../pages/mobile_scanner_page.dart';

typedef ScannerLauncherOverride =
    Future<String?> Function(BuildContext context);

Future<String?> openMobileScanner({
  required BuildContext context,
  required String title,
  String? description,
  ScannerLauncherOverride? overrideLauncher,
}) async {
  final launcher = overrideLauncher;
  if (launcher != null) {
    return launcher(context);
  }

  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => MobileScannerPage(title: title, description: description),
    ),
  );
}
