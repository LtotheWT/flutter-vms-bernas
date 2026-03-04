import 'package:flutter/material.dart';

class WhitelistStatusPresentation {
  const WhitelistStatusPresentation({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  static WhitelistStatusPresentation fromCode(String code) {
    final normalized = code.trim().toUpperCase();
    switch (normalized) {
      case 'ACTIVE':
      case 'A':
        return const WhitelistStatusPresentation(
          label: 'Active',
          backgroundColor: Color(0xFFDDF5E6),
          foregroundColor: Color(0xFF146C2E),
        );
      case 'INACTIVE':
      case 'I':
        return const WhitelistStatusPresentation(
          label: 'Inactive',
          backgroundColor: Color(0xFFFFE1E1),
          foregroundColor: Color(0xFF9B1C1C),
        );
      default:
        final label = normalized.isEmpty ? 'Unknown' : normalized;
        return WhitelistStatusPresentation(
          label: label,
          backgroundColor: const Color(0xFFE9EAEC),
          foregroundColor: const Color(0xFF40464F),
        );
    }
  }
}

class WhitelistStatusBadge extends StatelessWidget {
  const WhitelistStatusBadge({super.key, required this.statusCode});

  final String statusCode;

  @override
  Widget build(BuildContext context) {
    final presentation = WhitelistStatusPresentation.fromCode(statusCode);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: presentation.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          presentation.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: presentation.foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
