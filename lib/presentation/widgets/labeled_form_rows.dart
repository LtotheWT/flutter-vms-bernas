import 'package:flutter/material.dart';

class LabeledFieldLabel extends StatelessWidget {
  const LabeledFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: colorScheme.error),
            ),
        ],
      ),
    );
  }
}

class FormRowDivider extends StatelessWidget {
  const FormRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(height: 1, thickness: 1, color: colorScheme.surface);
  }
}

class LabeledTextInputRow extends StatelessWidget {
  const LabeledTextInputRow({
    super.key,
    required this.label,
    this.isRequired = false,
    required this.controller,
    this.hintText = 'Please input',
    this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 4),
        AppTextInputField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          hintText: hintText,
        ),
        const SizedBox(height: 6),
        const FormRowDivider(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class AppTextInputField extends StatelessWidget {
  const AppTextInputField({
    super.key,
    required this.controller,
    this.hintText = 'Please input',
    this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.validator,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding = EdgeInsets.zero,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: contentPadding,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(
          minHeight: 24,
          minWidth: 24,
        ),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 24,
          minWidth: 24,
        ),
      ),
    );
  }
}

class LabeledSelectRow extends StatelessWidget {
  const LabeledSelectRow({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.isRequired = false,
    this.enabled = true,
    this.hasError = false,
    this.helperText,
  });

  final String label;
  final String placeholder;
  final VoidCallback onTap;
  final String? value;
  final bool isRequired;
  final bool enabled;
  final bool hasError;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayText = value ?? placeholder;
    final displayColor = value == null
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 4),
        InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      color: enabled
                          ? displayColor
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              helperText!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          )
        else if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '$label is required.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
        const SizedBox(height: 6),
        const FormRowDivider(),
        const SizedBox(height: 8),
      ],
    );
  }
}
