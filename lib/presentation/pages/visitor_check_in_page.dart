import 'package:flutter/material.dart';

import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/info_row.dart';

class VisitorCheckInPage extends StatefulWidget {
  const VisitorCheckInPage({super.key, required this.isCheckIn});

  final bool isCheckIn;

  @override
  State<VisitorCheckInPage> createState() => _VisitorCheckInPageState();
}

class _VisitorCheckInPageState extends State<VisitorCheckInPage> {
  final _scanController = TextEditingController();
  final _physicalScanController = TextEditingController();
  final Set<int> _selectedIndexes = <int>{};
  bool _hasScanResult = false;
  int _resultTabIndex = 0;
  final List<_VisitorRow> _visitors = [
    const _VisitorRow(
      name: 'AAAA',
      idNumber: 'AAAA',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:00 AM',
      checkOutDate: '-',
      hasPhoto: true,
    ),
    const _VisitorRow(
      name: 'BBBB',
      idNumber: 'BBB',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:05 AM',
      checkOutDate: '-',
      hasPhoto: false,
    ),
    const _VisitorRow(
      name: 'CCCC',
      idNumber: 'CCCC',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:10 AM',
      checkOutDate: '-',
      hasPhoto: true,
    ),
    const _VisitorRow(
      name: 'DDDD',
      idNumber: 'DDD',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:15 AM',
      checkOutDate: '-',
      hasPhoto: false,
    ),
  ];

  @override
  void dispose() {
    _scanController.dispose();
    _physicalScanController.dispose();
    super.dispose();
  }

  void _onScanSuccess() {
    setState(() {
      _hasScanResult = true;
      _resultTabIndex = 0;
    });
  }

  void _onClearScan() {
    setState(() {
      _scanController.clear();
      _physicalScanController.clear();
      _hasScanResult = false;
      _resultTabIndex = 0;
      _selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                        onTrailingTap: _onScanSuccess,
                      ),
                      const SizedBox(height: 8),
                      _FlatInputField(
                        controller: _physicalScanController,
                        label: 'Scan Physical Tag',
                        hintText: 'Please input',
                        trailingIcon: Icons.nfc,
                        onTrailingTap: _onScanSuccess,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppFilledButton(
                              onPressed: _onScanSuccess,
                              child: const Text('Simulate Scan Success'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppOutlinedButton(
                            onPressed: _onClearScan,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_hasScanResult)
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (_hasScanResult)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySegmentHeaderDelegate(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _ResultTabBar(
                    selectedIndex: _resultTabIndex,
                    visitorCount: _visitors.length,
                    onChanged: (index) =>
                        setState(() => _resultTabIndex = index),
                  ),
                ),
                height: 56,
              ),
            ),
          if (_hasScanResult)
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
          if (_hasScanResult && _resultTabIndex == 0)
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
                        const InfoRow(
                          label: 'Invitation ID',
                          value: 'IV20251200074',
                        ),
                        const InfoRow(
                          label: 'Department',
                          value: 'Admin Center',
                        ),
                        const InfoRow(label: 'Purpose', value: 'Meeting'),
                        const InfoRow(label: 'Site', value: 'FACTORY1 T'),
                        const InfoRow(
                          label: 'Company',
                          value: 'JOHNHANSON LIMITED',
                        ),
                        const InfoRow(label: 'Contact', value: '012-3456789'),
                        const Divider(height: 24),
                        const InfoRow(label: 'Visitor Type', value: 'Visitor'),
                        const InfoRow(label: 'Invite By', value: 'Suraya'),
                        const InfoRow(label: 'Work Level', value: 'Low'),
                        const InfoRow(
                          label: 'Vehicle Plate',
                          value: 'WSD 011234',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_hasScanResult && _resultTabIndex == 1)
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
                      value:
                          _selectedIndexes.length == _visitors.length &&
                          _visitors.isNotEmpty,
                      onChanged: _visitors.isEmpty
                          ? null
                          : (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedIndexes
                                    ..clear()
                                    ..addAll(
                                      List<int>.generate(
                                        _visitors.length,
                                        (index) => index,
                                      ),
                                    );
                                } else {
                                  _selectedIndexes.clear();
                                }
                              });
                            },
                      title: Text(
                        'Select all (${_selectedIndexes.length}/${_visitors.length})',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          if (_hasScanResult && _resultTabIndex == 1)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  return _VisitorCard(
                    visitor: _visitors[i],
                    selected: _selectedIndexes.contains(i),
                    onSelected: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedIndexes.add(i);
                        } else {
                          _selectedIndexes.remove(i);
                        }
                      });
                    },
                  );
                }, childCount: _visitors.length),
              ),
            ),
          if (_hasScanResult)
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
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
          onPressed: _selectedIndexes.isEmpty ? null : () {},
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
    required this.onSelected,
  });

  final _VisitorRow visitor;
  final bool selected;
  final ValueChanged<bool?> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(value: selected, onChanged: onSelected),
                Expanded(
                  child: Text(
                    visitor.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            InfoRow(label: 'Name', value: visitor.name),
            InfoRow(label: 'IC/Passport', value: visitor.idNumber),
            InfoRow(label: 'Check In/Out', value: visitor.checkStatus),
            InfoRow(label: 'Check In Date', value: visitor.checkInDate),
            InfoRow(label: 'Check Out Date', value: visitor.checkOutDate),
            const InfoRow(label: 'Gate In', value: 'F1_A'),
            const InfoRow(label: 'Gate Out', value: '-'),
            const InfoRow(label: 'Check In By', value: 'ryan'),
            const InfoRow(label: 'Check Out By', value: '-'),
            const SizedBox(height: 6),
            const _FlatInputField(
              label: 'Physical Tag',
              hintText: 'Please input',
              trailingIcon: Icons.qr_code_scanner,
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
                _PhotoMock(hasPhoto: visitor.hasPhoto),
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

class _VisitorRow {
  const _VisitorRow({
    required this.name,
    required this.idNumber,
    required this.checkStatus,
    required this.checkInDate,
    required this.checkOutDate,
    required this.hasPhoto,
  });

  final String name;
  final String idNumber;
  final String checkStatus;
  final String checkInDate;
  final String checkOutDate;
  final bool hasPhoto;
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
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text('$label: $value'),
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
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

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
      color: colorScheme.outline.withOpacity(0.25),
    );
  }
}
