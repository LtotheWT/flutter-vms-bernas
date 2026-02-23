import 'package:flutter/material.dart';

class InvitationStatusPresentation {
  const InvitationStatusPresentation({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  static InvitationStatusPresentation fromCode(String code) {
    final normalized = code.trim().toUpperCase();
    switch (normalized) {
      case 'NEW':
        return const InvitationStatusPresentation(
          label: 'New',
          backgroundColor: Color(0xFFDDEBFF),
          foregroundColor: Color(0xFF0F4C9A),
        );
      case 'APPROVED':
        return const InvitationStatusPresentation(
          label: 'Approved',
          backgroundColor: Color(0xFFDDF5E6),
          foregroundColor: Color(0xFF146C2E),
        );
      case 'REJECTED':
        return const InvitationStatusPresentation(
          label: 'Rejected',
          backgroundColor: Color(0xFFFFE1E1),
          foregroundColor: Color(0xFF9B1C1C),
        );
      case 'ARRIVED':
      case 'CHECKED_IN':
        return const InvitationStatusPresentation(
          label: 'Arrived',
          backgroundColor: Color(0xFFDDF4F6),
          foregroundColor: Color(0xFF0B5F6B),
        );
      default:
        final fallback = _humanizeStatus(code);
        return InvitationStatusPresentation(
          label: fallback,
          backgroundColor: const Color(0xFFE9EAEC),
          foregroundColor: const Color(0xFF40464F),
        );
    }
  }

  static String _humanizeStatus(String code) {
    final source = code.trim();
    if (source.isEmpty) {
      return 'Unknown';
    }

    final normalized = source.replaceAll('_', ' ').toLowerCase();
    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class InvitationStatusBadge extends StatelessWidget {
  const InvitationStatusBadge({super.key, required this.statusCode});

  final String statusCode;

  @override
  Widget build(BuildContext context) {
    final presentation = InvitationStatusPresentation.fromCode(statusCode);
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
