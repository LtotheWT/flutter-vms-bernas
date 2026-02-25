import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/visitor_lookup_item_entity.dart';
import '../state/visitor_check_in_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/info_row.dart';

class VisitorCheckInPage extends ConsumerStatefulWidget {
  const VisitorCheckInPage({super.key, required this.isCheckIn});

  final bool isCheckIn;

  @override
  ConsumerState<VisitorCheckInPage> createState() => _VisitorCheckInPageState();
}

class _VisitorCheckInPageState extends ConsumerState<VisitorCheckInPage> {
  final _scanController = TextEditingController();
  final _scanFocusNode = FocusNode();
  final Set<int> _selectedIndexes = <int>{};
  int _resultTabIndex = 0;
  late final ProviderSubscription<VisitorCheckState> _stateSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = ref.listenManual<VisitorCheckState>(
      visitorCheckControllerProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }

        if (_scanController.text != next.searchInput) {
          _scanController.value = TextEditingValue(
            text: next.searchInput,
            selection: TextSelection.collapsed(offset: next.searchInput.length),
          );
        }

        final hadLookup = previous?.lookup != null;
        final hasLookup = next.lookup != null;
        if (hadLookup != hasLookup || previous?.lookup != next.lookup) {
          setState(() {
            _selectedIndexes.clear();
            _resultTabIndex = 0;
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _stateSubscription.close();
    _scanController.dispose();
    _scanFocusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final controller = ref.read(visitorCheckControllerProvider.notifier);
    controller.updateSearchInput(_scanController.text);
    await controller.search(isCheckIn: widget.isCheckIn);
  }

  void _clear() {
    ref.read(visitorCheckControllerProvider.notifier).clearAll();
  }

  String _displayOrDash(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  String _visitorTypeDisplay(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '-';
    }
    final parts = text.split('_');
    if (parts.length == 2 && parts.last.trim().isNotEmpty) {
      return parts.last.trim();
    }
    return text;
  }

  String _visitStatus(VisitorLookupItemEntity visitor) {
    final hasCheckOut = visitor.checkOutTime.trim().isNotEmpty;
    if (hasCheckOut) {
      return 'OUT';
    }
    final hasCheckIn = visitor.checkInTime.trim().isNotEmpty;
    if (hasCheckIn) {
      return 'IN';
    }
    return '-';
  }

  bool _isEligibleForCurrentAction(VisitorLookupItemEntity visitor) {
    if (widget.isCheckIn) {
      return visitor.checkInTime.trim().isEmpty;
    }
    return visitor.checkOutTime.trim().isEmpty;
  }

  String? _disabledReasonForCurrentAction(VisitorLookupItemEntity visitor) {
    if (_isEligibleForCurrentAction(visitor)) {
      return null;
    }
    return widget.isCheckIn ? 'Already checked in' : 'Already checked out';
  }

  Set<int> _eligibleIndexes(List<VisitorLookupItemEntity> visitors) {
    final result = <int>{};
    for (var i = 0; i < visitors.length; i++) {
      if (_isEligibleForCurrentAction(visitors[i])) {
        result.add(i);
      }
    }
    return result;
  }

  String _formatDateTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return text;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();

    final hour24 = parsed.hour;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final meridiem = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = ((hour24 + 11) % 12 + 1).toString().padLeft(2, '0');

    return '$day/$month/$year $hour12:$minute $meridiem';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitorCheckControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final lookup = state.lookup;
    final visitors = lookup?.visitors ?? const <VisitorLookupItemEntity>[];
    final hasResult = lookup != null;
    final eligibleIndexes = _eligibleIndexes(visitors);
    final selectedEligibleCount = _selectedIndexes
        .where(eligibleIndexes.contains)
        .length;
    final hasEligibleVisitors = eligibleIndexes.isNotEmpty;
    final allEligibleSelected =
        hasEligibleVisitors && selectedEligibleCount == eligibleIndexes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCheckIn ? 'Visitor Check-In' : 'Visitor Check-Out',
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Scan',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _FlatInputField(
                        controller: _scanController,
                        label: 'Scan QR Code',
                        hintText: 'Please input',
                        trailingIcon: Icons.qr_code_scanner,
                        onChanged: ref
                            .read(visitorCheckControllerProvider.notifier)
                            .updateSearchInput,
                        onTrailingTap: () => _scanFocusNode.requestFocus(),
                        focusNode: _scanFocusNode,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppFilledButton(
                              onPressed: state.isLoading ? null : _search,
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Search'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppOutlinedButton(
                            onPressed: state.isLoading ? null : _clear,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      if (state.errorMessage != null &&
                          state.errorMessage!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (hasResult) const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (hasResult)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySegmentHeaderDelegate(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _ResultTabBar(
                    selectedIndex: _resultTabIndex,
                    visitorCount: visitors.length,
                    onChanged: (index) =>
                        setState(() => _resultTabIndex = index),
                  ),
                ),
                height: 56,
              ),
            ),
          if (hasResult) const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (hasResult && _resultTabIndex == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Visitor Summary',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InfoRow(
                          label: 'Invitation ID',
                          value: _displayOrDash(lookup.invitationId),
                        ),
                        InfoRow(
                          label: 'Department',
                          value: _displayOrDash(
                            lookup.departmentDesc.trim().isNotEmpty
                                ? lookup.departmentDesc
                                : lookup.department,
                          ),
                        ),
                        InfoRow(
                          label: 'Purpose',
                          value: _displayOrDash(lookup.purpose),
                        ),
                        InfoRow(
                          label: 'Site',
                          value: _displayOrDash(
                            lookup.siteDesc.trim().isNotEmpty
                                ? lookup.siteDesc
                                : lookup.site,
                          ),
                        ),
                        InfoRow(
                          label: 'Company',
                          value: _displayOrDash(lookup.company),
                        ),
                        InfoRow(
                          label: 'Contact',
                          value: _displayOrDash(lookup.contactNumber),
                        ),
                        const Divider(height: 24),
                        InfoRow(
                          label: 'Visitor Type',
                          value: _visitorTypeDisplay(lookup.visitorType),
                        ),
                        InfoRow(
                          label: 'Invite By',
                          value: _displayOrDash(lookup.inviteBy),
                        ),
                        InfoRow(
                          label: 'Work Level',
                          value: _displayOrDash(lookup.workLevel),
                        ),
                        InfoRow(
                          label: 'Vehicle Plate',
                          value: _displayOrDash(lookup.vehiclePlateNumber),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (hasResult && _resultTabIndex == 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Visitor List',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: allEligibleSelected,
                      onChanged: hasEligibleVisitors
                          ? (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedIndexes
                                    ..clear()
                                    ..addAll(eligibleIndexes);
                                } else {
                                  _selectedIndexes.clear();
                                }
                              });
                            }
                          : null,
                      title: Text(
                        'Select all ($selectedEligibleCount/${eligibleIndexes.length})',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          if (hasResult && _resultTabIndex == 1)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final visitor = visitors[i];
                  final isEligible = _isEligibleForCurrentAction(visitor);
                  return _VisitorCard(
                    visitor: visitor,
                    selected: _selectedIndexes.contains(i),
                    isEligible: isEligible,
                    ineligibleReason: _disabledReasonForCurrentAction(visitor),
                    checkStatus: _visitStatus(visitor),
                    checkInDate: _formatDateTime(visitor.checkInTime),
                    checkOutDate: _formatDateTime(visitor.checkOutTime),
                    onSelected: isEligible
                        ? (checked) {
                            setState(() {
                              if (checked == true) {
                                if (_isEligibleForCurrentAction(visitor)) {
                                  _selectedIndexes.add(i);
                                }
                              } else {
                                _selectedIndexes.remove(i);
                              }
                            });
                          }
                        : null,
                  );
                }, childCount: visitors.length),
              ),
            ),
          if (hasResult)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Take Photo',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppOutlinedButtonIcon(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PhotoThumb(hasPhoto: true),
                            _PhotoThumb(hasPhoto: false),
                            _PhotoThumb(hasPhoto: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: AppFilledButton(
          onPressed: selectedEligibleCount == 0 ? null : () {},
          child: Text(
            widget.isCheckIn ? 'Confirm Check-In' : 'Confirm Check-Out',
          ),
        ),
      ),
    );
  }
}

class _VisitorCard extends StatelessWidget {
  const _VisitorCard({
    required this.visitor,
    required this.selected,
    required this.isEligible,
    required this.ineligibleReason,
    required this.checkStatus,
    required this.checkInDate,
    required this.checkOutDate,
    required this.onSelected,
  });

  final VisitorLookupItemEntity visitor;
  final bool selected;
  final bool isEligible;
  final String? ineligibleReason;
  final String checkStatus;
  final String checkInDate;
  final String checkOutDate;
  final ValueChanged<bool?>? onSelected;

  String _displayOrDash(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(value: selected, onChanged: onSelected),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayOrDash(visitor.name),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isEligible && ineligibleReason != null)
                        Text(
                          ineligibleReason!,
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            InfoRow(label: 'Name', value: _displayOrDash(visitor.name)),
            InfoRow(
              label: 'IC/Passport',
              value: _displayOrDash(visitor.icPassport),
            ),
            InfoRow(label: 'Check In/Out', value: checkStatus),
            InfoRow(label: 'Check In Date', value: checkInDate),
            InfoRow(label: 'Check Out Date', value: checkOutDate),
            const InfoRow(label: 'Gate In', value: '-'),
            const InfoRow(label: 'Gate Out', value: '-'),
            const InfoRow(label: 'Check In By', value: '-'),
            const InfoRow(label: 'Check Out By', value: '-'),
            InfoRow(
              label: 'Physical Tag',
              value: _displayOrDash(visitor.physicalTag),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    'Visitor Photo',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const _PhotoMock(hasPhoto: false),
                const SizedBox(width: 12),
                AppOutlinedButtonIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTabBar extends StatelessWidget {
  const _ResultTabBar({
    required this.selectedIndex,
    required this.visitorCount,
    required this.onChanged,
  });

  final int selectedIndex;
  final int visitorCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _ResultTabChip(
                label: 'Summary',
                selected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ResultTabChip(
                label: 'Visitor List ($visitorCount)',
                selected: selectedIndex == 1,
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySegmentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickySegmentHeaderDelegate({
    required this.child,
    required this.backgroundColor,
    required this.height,
  });

  final Widget child;
  final Color backgroundColor;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: ColoredBox(color: backgroundColor, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySegmentHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.height != height;
  }
}

class _ResultTabChip extends StatelessWidget {
  const _ResultTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoMock extends StatelessWidget {
  const _PhotoMock({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 72,
        width: 72,
        color: hasPhoto ? colorScheme.primaryContainer : Colors.grey.shade300,
        child: Icon(
          hasPhoto ? Icons.check_circle : Icons.person,
          size: 30,
          color: hasPhoto ? colorScheme.onPrimaryContainer : Colors.black54,
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _PhotoMock(hasPhoto: hasPhoto),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, size: 12),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minHeight: 20, minWidth: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlatInputField extends StatelessWidget {
  const _FlatInputField({
    required this.label,
    required this.hintText,
    this.controller,
    this.trailingIcon,
    this.onTrailingTap,
    this.onChanged,
    this.focusNode,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onTrailingTap,
                icon: Icon(trailingIcon),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        const _FieldRowDivider(),
      ],
    );
  }
}

class _FieldRowDivider extends StatelessWidget {
  const _FieldRowDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 0.6,
      color: colorScheme.outline.withValues(alpha: 0.25),
    );
  }
}
