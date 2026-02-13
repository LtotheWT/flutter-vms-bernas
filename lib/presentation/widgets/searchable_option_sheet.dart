import 'package:flutter/material.dart';

import 'labeled_form_rows.dart';

Future<String?> showSearchableOptionSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  String? currentValue,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SearchableOptionSheet(
      title: title,
      options: options,
      currentValue: currentValue,
    ),
  );
}

class _SearchableOptionSheet extends StatefulWidget {
  const _SearchableOptionSheet({
    required this.title,
    required this.options,
    this.currentValue,
  });

  final String title;
  final List<String> options;
  final String? currentValue;

  @override
  State<_SearchableOptionSheet> createState() => _SearchableOptionSheetState();
}

class _SearchableOptionSheetState extends State<_SearchableOptionSheet> {
  late final TextEditingController _searchController;
  late List<String> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredOptions = _normalizeDisplayOrder(widget.options);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      final matchedOptions = q.isEmpty
          ? widget.options
          : widget.options
                .where((item) => item.toLowerCase().contains(q))
                .toList(growable: false);
      _filteredOptions = _normalizeDisplayOrder(matchedOptions);
    });
  }

  List<String> _normalizeDisplayOrder(Iterable<String> options) {
    final nonBlank = <String>[];
    final blank = <String>[];
    for (final option in options) {
      if (_isBlankOption(option)) {
        blank.add(option);
      } else {
        nonBlank.add(option);
      }
    }
    return <String>[...nonBlank, ...blank];
  }

  bool _isBlankOption(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty || normalized == '(blank)';
  }

  ({String primary, String? secondary}) _splitLabel(String raw) {
    final separatorIndex = raw.indexOf(' - ');
    if (separatorIndex < 0) {
      return (primary: raw, secondary: null);
    }

    final primary = raw.substring(0, separatorIndex).trim();
    final secondary = raw.substring(separatorIndex + 3).trim();
    return (
      primary: primary.isEmpty ? raw : primary,
      secondary: secondary.isEmpty ? null : secondary,
    );
  }

  Widget _buildOptionRow({
    required BuildContext context,
    required String option,
    required bool selected,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final label = _splitLabel(option);
    final isBlank = _isBlankOption(option);

    final primaryColor = isBlank
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;
    final secondaryColor = isBlank
        ? colorScheme.onSurfaceVariant.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).pop(option),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected
                ? colorScheme.primaryContainer.withOpacity(0.35)
                : Colors.transparent,
            border: selected
                ? Border.all(color: colorScheme.primary.withOpacity(0.55))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.primary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (label.secondary != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        label.secondary!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: secondaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (selected)
                Icon(Icons.check, size: 19, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            AppTextInputField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              hintText: 'Search...',
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: Icon(
                Icons.search,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Divider(height: 1, thickness: 1, color: colorScheme.surface),
            const SizedBox(height: 8),
            SizedBox(
              height: 320,
              child: _filteredOptions.isEmpty
                  ? const Center(child: Text('No results'))
                  : ListView.separated(
                      itemCount: _filteredOptions.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.surface,
                      ),
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        final selected = option == widget.currentValue;
                        return _buildOptionRow(
                          context: context,
                          option: option,
                          selected: selected,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
