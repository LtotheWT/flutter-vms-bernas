import 'package:flutter/material.dart';

class AppDropdownMenuFormField<T> extends StatelessWidget {
  const AppDropdownMenuFormField({
    super.key,
    this.helperText,
    required this.entries,
    this.initialSelection,
    this.onSelected,
    this.validator,
    this.autovalidateMode,
    this.enableSearch = true,
    this.enableFilter = true,
    this.hintText,
    this.width,
  });

  final String? helperText;
  final List<DropdownMenuEntry<T>> entries;
  final T? initialSelection;
  final ValueChanged<T?>? onSelected;
  final String? Function(T?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool enableSearch;
  final bool enableFilter;
  final String? hintText;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialSelection,
      validator: validator,
      autovalidateMode: autovalidateMode,
      builder: (state) {
        return DropdownMenu<T>(
          initialSelection: state.value,
          onSelected: (value) {
            state.didChange(value);
            onSelected?.call(value);
          },

          searchCallback: (entries, query) {
            if (query.isEmpty) return null;
            final int index = entries.indexWhere(
              (entry) =>
                  entry.label.toLowerCase().contains(query.toLowerCase()),
            );
            return index != -1 ? index : null;
          },
          errorText: state.errorText,
          width: width ?? double.infinity,
          enableSearch: enableSearch,
          enableFilter: enableFilter,
          helperText: helperText,
          hintText: hintText,
          dropdownMenuEntries: entries,
          requestFocusOnTap: true,
        );
      },
    );
  }
}

class AppDropdownMenuEntry<T> extends DropdownMenuEntry<T> {
  AppDropdownMenuEntry({
    required super.value,
    required super.label,
    super.enabled = true,
  });
}
