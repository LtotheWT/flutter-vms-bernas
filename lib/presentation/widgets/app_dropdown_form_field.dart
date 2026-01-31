import 'package:flutter/material.dart';

class AppDropdownFormField<T> extends StatelessWidget {
  const AppDropdownFormField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.isExpanded = true,
    this.hint,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool isExpanded;
  final Widget? hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: isExpanded,
      hint: hint,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class AppDropdownMenuItem<T> extends DropdownMenuItem<T> {
  AppDropdownMenuItem({
    super.key,
    required super.value,
    required String label,
  }) : super(child: Text(label));
}
