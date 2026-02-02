import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.barrierColor = Colors.black26,
    this.indicator,
  });

  final bool isLoading;
  final Widget child;
  final Color barrierColor;
  final Widget? indicator;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ModalBarrier(dismissible: false, color: barrierColor),
        ),
        Center(child: indicator ?? const CircularProgressIndicator()),
      ],
    );
  }
}
