import 'package:flutter/material.dart';

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.fullWidth = false,
    this.minimumHeight = 44,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool fullWidth;
  final double minimumHeight;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = FilledButton.styleFrom(
      minimumSize: Size(fullWidth ? double.infinity : 0, minimumHeight),
    ).merge(style);

    return FilledButton(
      onPressed: onPressed,
      style: effectiveStyle,
      child: child,
    );
  }
}
