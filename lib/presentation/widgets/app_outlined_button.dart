import 'package:flutter/material.dart';

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
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
    final effectiveStyle = OutlinedButton.styleFrom(
      minimumSize: Size(fullWidth ? double.infinity : 0, minimumHeight),
    ).merge(style);

    return OutlinedButton(
      onPressed: onPressed,
      style: effectiveStyle,
      child: child,
    );
  }
}

class AppOutlinedButtonIcon extends StatelessWidget {
  const AppOutlinedButtonIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.fullWidth = false,
    this.minimumHeight = 44,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final bool fullWidth;
  final double minimumHeight;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = OutlinedButton.styleFrom(
      minimumSize: Size(fullWidth ? double.infinity : 0, minimumHeight),
    ).merge(style);

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: effectiveStyle,
      icon: icon,
      label: label,
    );
  }
}
