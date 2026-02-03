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
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.menuHeight = 240,
    this.openUpwards = true,
    this.controller,
    this.menuItemHeight = 48,
    this.menuVerticalPadding = 0,
  });

  final List<DropdownMenuEntry<T>> entries;
  final T? initialSelection;
  final ValueChanged<T?>? onSelected;
  final String? Function(T?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool enableSearch;
  final bool enabled;
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
  double? _anchorWidth;
  final ScrollController _scrollController = ScrollController();
  bool _pendingScrollToSelection = false;
  final FocusNode _focusNode = FocusNode();
  FormFieldState<T>? _fieldState;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _filteredEntries = List<DropdownMenuEntry<T>>.from(widget.entries);
    _syncControllerText(widget.initialSelection);
    _focusNode.addListener(_handleFocusChange);
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
    _scrollController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
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

  void _handleFocusChange() {
    if (_focusNode.hasFocus) return;
    _syncSelectionFromText();
  }

  void _syncSelectionFromText() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _fieldState?.didChange(null);
      widget.onSelected?.call(null);
      return;
    }
    final match = widget.entries.where((e) => e.label == text);
    if (match.isEmpty) {
      _syncControllerText(_fieldState?.value);
      return;
    }
    final value = match.first.value;
    if (_fieldState?.value != value) {
      _fieldState?.didChange(value);
      widget.onSelected?.call(value);
    }
  }

  void _updateAnchorHeight() {
    final context = _anchorKey.currentContext;
    if (context == null) return;
    final box = context.findRenderObject();
    if (box is! RenderBox) return;
    final height = box.size.height;
    final width = box.size.width;
    if (_anchorHeight != height || _anchorWidth != width) {
      setState(() {
        _anchorHeight = height;
        _anchorWidth = width;
      });
    }
  }

  double _effectiveMenuHeight() {
    final int count = _filteredEntries.isEmpty ? 1 : _filteredEntries.length;
    final int maxVisible = (widget.menuHeight / widget.menuItemHeight)
        .floor()
        .clamp(1, count);
    final int visibleCount = math.min(count, maxVisible);
    return visibleCount * widget.menuItemHeight;
  }

  void _scrollToSelection() {
    if (!_scrollController.hasClients) return;
    final selected = widget.initialSelection;
    if (selected == null) return;
    final int index = _filteredEntries.indexWhere(
      (entry) => entry.value == selected,
    );
    if (index == -1) return;
    final double target = index * widget.menuItemHeight;
    _scrollController.jumpTo(
      target.clamp(0, _scrollController.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAnchorHeight());

    return FormField<T>(
      initialValue: widget.initialSelection,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (state) {
        _fieldState = state;
        final List<Widget> menuChildren = _filteredEntries.isEmpty
            ? <Widget>[
                const MenuItemButton(
                  onPressed: null,
                  child: Text('No results'),
                ),
              ]
            : <Widget>[
                SizedBox(
                  height: _effectiveMenuHeight(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    primary: false,
                    itemExtent: widget.menuItemHeight,
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      final labelWidget =
                          entry.labelWidget ?? Text(entry.label);
                      final bool isSelected = entry.value == state.value;
                      final ButtonStyle? selectedStyle = isSelected
                          ? const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Color(0xFFE0E0E0),
                              ),
                            )
                          : null;

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
                        style: selectedStyle ?? entry.style,
                        child: labelWidget,
                      );
                    },
                  ),
                ),
              ];

        return MenuAnchor(
          controller: _menuController,
          crossAxisUnconstrained: false,
          alignmentOffset: widget.openUpwards
              ? Offset(0, -(_effectiveMenuHeight() + (_anchorHeight ?? 0)))
              : Offset.zero,
          style: MenuStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            minimumSize: _anchorWidth == null
                ? null
                : WidgetStatePropertyAll(Size(_anchorWidth!, 0)),
            maximumSize: _anchorWidth == null
                ? WidgetStatePropertyAll(Size.fromHeight(widget.menuHeight))
                : WidgetStatePropertyAll(
                    Size(_anchorWidth!, widget.menuHeight),
                  ),
          ),
          menuChildren: menuChildren,
          builder: (context, controller, child) {
            return TextFormField(
              key: _anchorKey,
              controller: _controller,
              enabled: widget.enabled,
              focusNode: _focusNode,
              readOnly: !widget.enableSearch || !widget.enabled,
              onTap: () {
                if (!widget.enabled) return;
                _updateAnchorHeight();
                _pendingScrollToSelection = true;
                controller.open();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_pendingScrollToSelection) {
                    _scrollToSelection();
                    _pendingScrollToSelection = false;
                  }
                });
              },
              onChanged: (value) {
                if (!widget.enabled) return;
                _filterEntries(value);
                if (!controller.isOpen) {
                  controller.open();
                }
              },
              onEditingComplete: _syncSelectionFromText,
              decoration: InputDecoration(
                hintText: widget.hintText,
                helperText: widget.helperText,
                errorText: state.errorText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: widget.enabled
                      ? () {
                        _updateAnchorHeight();
                        _pendingScrollToSelection = true;
                        controller.isOpen ? controller.close() : controller.open();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pendingScrollToSelection) {
                            _scrollToSelection();
                            _pendingScrollToSelection = false;
                          }
                        });
                      }
                      : null,
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
