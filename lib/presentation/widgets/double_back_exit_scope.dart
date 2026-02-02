import 'package:flutter/material.dart';

import 'app_snackbar.dart';

class DoubleBackExitScope extends StatefulWidget {
  const DoubleBackExitScope({
    super.key,
    required this.child,
    required this.hasUnsavedChanges,
    required this.isBlocked,
    this.snackBarMessage = 'Press back again to exit',
    this.interval = const Duration(seconds: 2),
  });

  final Widget child;
  final bool hasUnsavedChanges;
  final bool isBlocked;
  final String snackBarMessage;
  final Duration interval;

  @override
  State<DoubleBackExitScope> createState() => _DoubleBackExitScopeState();
}

class _DoubleBackExitScopeState extends State<DoubleBackExitScope> {
  DateTime? _lastBackPressedAt;
  bool _allowPop = false;

  void _handleBackPressed() {
    if (widget.isBlocked) {
      return;
    }

    if (!widget.hasUnsavedChanges) {
      _allowPopAndExit();
      return;
    }

    final now = DateTime.now();
    final lastPressed = _lastBackPressedAt;
    if (lastPressed == null || now.difference(lastPressed) > widget.interval) {
      _lastBackPressedAt = now;
      showAppSnackBar(context, widget.snackBarMessage);
      return;
    }

    _allowPopAndExit();
  }

  void _allowPopAndExit() {
    if (_allowPop) {
      return;
    }
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleBackPressed();
      },
      child: widget.child,
    );
  }
}
