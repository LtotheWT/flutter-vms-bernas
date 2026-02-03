import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppDropdownMenuFormField<T> extends StatefulWidget {
  const AppDropdownMenuFormField({
    super.key,
    required this.entries,
    this.initialSelection,
    this.onSelected,
    this.validator,
    this.autovalidateMode,
    this.enableSearch = true,
    this.hintText,
    this.helperText,
    this.menuHeight = 240,
    this.openUpwards = true,
    this.controller,
    this.menuItemHeight = 48,
    this.menuVerticalPadding = 16,
  });

  final List<DropdownMenuEntry<T>> entries;
  final T? initialSelection;
  final ValueChanged<T?>? onSelected;
  final String? Function(T?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool enableSearch;
  final String? hintText;
  final String? helperText;
  final double menuHeight;
  final bool openUpwards;
  final TextEditingController? controller;
  final double menuItemHeight;
  final double menuVerticalPadding;

  @override
  State<AppDropdownMenuFormField<T>> createState() =>
      _AppDropdownMenuFormFieldState<T>();
}

class _AppDropdownMenuFormFieldState<T>
    extends State<AppDropdownMenuFormField<T>> {
  late TextEditingController _controller;
  late bool _ownsController;
  late List<DropdownMenuEntry<T>> _filteredEntries;
  final MenuController _menuController = MenuController();
  final GlobalKey _anchorKey = GlobalKey();
  double? _anchorHeight;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _filteredEntries = List<DropdownMenuEntry<T>>.from(widget.entries);
    _syncControllerText(widget.initialSelection);
  }

  @override
  void didUpdateWidget(covariant AppDropdownMenuFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
    }
    if (oldWidget.entries != widget.entries) {
      _filteredEntries = List<DropdownMenuEntry<T>>.from(widget.entries);
    }
    if (oldWidget.initialSelection != widget.initialSelection) {
      _syncControllerText(widget.initialSelection);
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _syncControllerText(T? value) {
    if (value == null) {
      _controller.clear();
      return;
    }
    final matched = widget.entries.where((entry) => entry.value == value);
    if (matched.isEmpty) {
      _controller.clear();
      return;
    }
    _controller.text = matched.first.label;
  }

  void _filterEntries(String query) {
    if (!widget.enableSearch || query.trim().isEmpty) {
      setState(() {
        _filteredEntries = List<DropdownMenuEntry<T>>.from(widget.entries);
      });
      return;
    }
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredEntries = widget.entries
          .where((entry) => entry.label.toLowerCase().contains(lowerQuery))
          .toList(growable: false);
    });
  }

  void _updateAnchorHeight() {
    final context = _anchorKey.currentContext;
    if (context == null) return;
    final box = context.findRenderObject();
    if (box is! RenderBox) return;
    final height = box.size.height;
    if (_anchorHeight != height) {
      setState(() {
        _anchorHeight = height;
      });
    }
  }

  double _effectiveMenuHeight() {
    final int count = _filteredEntries.isEmpty ? 1 : _filteredEntries.length;
    final double estimated =
        (count * widget.menuItemHeight) + widget.menuVerticalPadding;
    return math.min(widget.menuHeight, estimated);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAnchorHeight());

    return FormField<T>(
      initialValue: widget.initialSelection,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (state) {
        final menuChildren = _filteredEntries.isEmpty
            ? <Widget>[
                const MenuItemButton(
                  onPressed: null,
                  child: Text('No results'),
                ),
              ]
            : _filteredEntries
                  .map((entry) {
                    final labelWidget = entry.labelWidget ?? Text(entry.label);
                    return MenuItemButton(
                      onPressed: entry.enabled
                          ? () {
                              state.didChange(entry.value);
                              widget.onSelected?.call(entry.value);
                              _controller.text = entry.label;
                              _menuController.close();
                            }
                          : null,
                      leadingIcon: entry.leadingIcon,
                      trailingIcon: entry.trailingIcon,
                      style: entry.style,
                      child: labelWidget,
                    );
                  })
                  .toList(growable: false);

        return MenuAnchor(
          controller: _menuController,
          alignmentOffset: widget.openUpwards
              ? Offset(0, -(_effectiveMenuHeight() + (_anchorHeight ?? 0)))
              : Offset.zero,
          style: MenuStyle(
            maximumSize: MaterialStatePropertyAll(
              Size.fromHeight(widget.menuHeight),
            ),
          ),
          menuChildren: menuChildren,
          builder: (context, controller, child) {
            return TextFormField(
              key: _anchorKey,
              controller: _controller,
              readOnly: !widget.enableSearch,
              onTap: () {
                _updateAnchorHeight();
                controller.open();
              },
              onChanged: (value) {
                _filterEntries(value);
                if (!controller.isOpen) {
                  controller.open();
                }
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                helperText: widget.helperText,
                errorText: state.errorText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    _updateAnchorHeight();
                    controller.isOpen ? controller.close() : controller.open();
                  },
                ),
              ),
            );
          },
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
    super.leadingIcon,
    super.trailingIcon,
    super.labelWidget,
    super.style,
  });
}
