import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.obscureText = false,
    this.minLines,
    this.maxLines,
    this.isDense = false,
    this.suffixIcon,
    this.onTap,
    this.validator,
  }) : assert(
         !obscureText ||
             ((minLines == null || minLines <= 1) &&
                 (maxLines == null || maxLines <= 1)),
         'Obscured fields cannot be multiline.',
       );

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final bool isDense;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final effectiveMinLines = obscureText ? 1 : minLines;
    final effectiveMaxLines = obscureText ? 1 : maxLines;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      obscureText: obscureText,
      minLines: effectiveMinLines,
      maxLines: effectiveMaxLines,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label.isEmpty ? null : label,
        suffixIcon: suffixIcon,
        isDense: isDense,
      ),
    );
  }
}
