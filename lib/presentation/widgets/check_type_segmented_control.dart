import 'package:flutter/material.dart';

import 'labeled_form_rows.dart';

class CheckTypeSegmentedControl extends StatelessWidget {
  const CheckTypeSegmentedControl({
    super.key,
    required this.isCheckIn,
    required this.onChanged,
    this.label = 'Check Type',
    this.isRequired = true,
    this.checkInLabel = 'Check-In',
    this.checkOutLabel = 'Check-Out',
  });

  final bool isCheckIn;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool isRequired;
  final String checkInLabel;
  final String checkOutLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildOption({
      required String text,
      required bool selected,
      required VoidCallback onTap,
      required Color selectedColor,
      required Color selectedTextColor,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? selectedTextColor : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                buildOption(
                  text: checkInLabel,
                  selected: isCheckIn,
                  onTap: () => onChanged(true),
                  selectedColor: Colors.green.shade600,
                  selectedTextColor: Colors.white,
                ),
                const SizedBox(width: 6),
                buildOption(
                  text: checkOutLabel,
                  selected: !isCheckIn,
                  onTap: () => onChanged(false),
                  selectedColor: colorScheme.error,
                  selectedTextColor: colorScheme.onError,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const FormRowDivider(),
      ],
    );
  }
}
