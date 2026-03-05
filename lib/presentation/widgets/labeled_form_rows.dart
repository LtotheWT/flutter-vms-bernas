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
  final double height;
  const FormRowDivider({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(height: height, thickness: 1, color: colorScheme.surface);
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
    this.enabled = true,
    this.inputFieldKey,
    this.suffixIcon,
    this.contentPadding = EdgeInsets.zero,
    this.obscureText = false,
    this.textInputAction,
    this.errorText,
  });

  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final Key? inputFieldKey;
  // For dense rows, prefer a compact trailing tap widget (GestureDetector/InkWell)
  // instead of IconButton to avoid extra spacing that changes input row height.
  final Widget? suffixIcon;
  final EdgeInsets contentPadding;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 4),
        AppTextInputField(
          inputFieldKey: inputFieldKey,
          enabled: enabled,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          hintText: hintText,
          suffixIcon: suffixIcon,
          contentPadding: contentPadding,
        ),
        if (errorText != null && errorText!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 4),
        const FormRowDivider(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class AppTextInputField extends StatelessWidget {
  const AppTextInputField({
    super.key,
    this.inputFieldKey,
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
    this.enabled = true,
    this.obscureText = false,
    this.textInputAction,
  });

  final Key? inputFieldKey;
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
  final bool enabled;
  final bool obscureText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      key: inputFieldKey,
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
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

class CompactSuffixTapIcon extends StatelessWidget {
  const CompactSuffixTapIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.enabled = true,
    this.padding = const EdgeInsets.all(4),
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: padding,
        child: Icon(
          icon,
          color: enabled
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurface.withValues(alpha: 0.38),
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
    this.onClear,
  });

  final String label;
  final String placeholder;
  final VoidCallback onTap;
  final String? value;
  final bool isRequired;
  final bool enabled;
  final bool hasError;
  final String? helperText;
  final VoidCallback? onClear;

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
                if (onClear != null && value != null)
                  IconButton(
                    onPressed: onClear,
                    tooltip: 'Clear',
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: enabled
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.outline,
                    ),
                    visualDensity: VisualDensity.compact,
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
