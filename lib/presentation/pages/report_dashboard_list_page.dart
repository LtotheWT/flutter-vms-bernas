import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReportDashboardListFilter {
  const ReportDashboardListFilter({
    required this.dashboardTitle,
    required this.listTitle,
    required this.status,
    required this.statusLabel,
    this.entity,
  });

  final String dashboardTitle;
  final String listTitle;
  final String status;
  final String statusLabel;
  final String? entity;
}

class ReportDashboardListPage extends StatefulWidget {
  const ReportDashboardListPage({super.key, this.filter});

  final ReportDashboardListFilter? filter;

  @override
  State<ReportDashboardListPage> createState() =>
      _ReportDashboardListPageState();
}

class _ReportDashboardListPageState extends State<ReportDashboardListPage> {
  bool _showFilterBar = true;

  List<_DashboardListItem> get _items {
    const base = [
      _DashboardListItem(
        invitationId: 'IV202509005',
        icNumber: '88112222221222',
        name: 'Nur Aina',
        visitFrom: '02/09/2025 03:30 PM',
        visitTo: '02/09/2025 03:31 PM',
        status: 'OUT',
        department: 'Admin Center',
      ),
      _DashboardListItem(
        invitationId: 'IV202509007',
        icNumber: '6577299993393',
        name: 'Ravi Kumar',
        visitFrom: '02/09/2025 03:54 PM',
        visitTo: '-',
        status: 'STILL_IN',
        department: 'Operations',
      ),
      _DashboardListItem(
        invitationId: 'IV202509012',
        icNumber: '800301065349',
        name: 'Aqil Faiz',
        visitFrom: '03/09/2025 02:23 PM',
        visitTo: '03/09/2025 02:25 PM',
        status: 'OUT',
        department: 'Security',
      ),
      _DashboardListItem(
        invitationId: 'IV202509016',
        icNumber: '830217045203',
        name: 'Suraya Ali',
        visitFrom: '03/09/2025 02:54 PM',
        visitTo: '03/09/2025 03:08 PM',
        status: 'OUT',
        department: 'Admin Center',
      ),
      _DashboardListItem(
        invitationId: 'IV202509017',
        icNumber: '940423045367',
        name: 'Nur Alia',
        visitFrom: '03/09/2025 02:57 PM',
        visitTo: '-',
        status: 'IN',
        department: 'Operations',
      ),
    ];

    final items = <_DashboardListItem>[];
    for (var i = 0; i < 30; i++) {
      final template = base[i % base.length];
      items.add(
        _DashboardListItem(
          invitationId: 'IV202509${(100 + i).toString().padLeft(3, '0')}',
          icNumber: template.icNumber,
          name: template.name,
          visitFrom: template.visitFrom,
          visitTo: template.visitTo,
          status: template.status,
          department: template.department,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final filteredItems = widget.filter == null
        ? _items
        : _items
            .where((item) => item.status == widget.filter!.status)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filter?.listTitle ?? 'Dashboard List'),
        centerTitle: true,
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          final direction = notification.direction;
          if (direction == ScrollDirection.reverse && _showFilterBar) {
            setState(() => _showFilterBar = false);
          } else if (direction == ScrollDirection.forward && !_showFilterBar) {
            setState(() => _showFilterBar = true);
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.filter == null || !_showFilterBar
                  ? const SizedBox.shrink(key: ValueKey('filter-hidden'))
                  : Column(
                      key: const ValueKey('filter-visible'),
                      children: [
                        _FilterSummary(
                          textTheme: textTheme,
                          colorScheme: colorScheme,
                          filter: widget.filter!,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
            ),
            Text(
              widget.filter?.listTitle ?? 'Activity',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final item in filteredItems) _ActivityCard(item: item),
            if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No records to display.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterSummary extends StatelessWidget {
  const _FilterSummary({
    required this.textTheme,
    required this.colorScheme,
    required this.filter,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final ReportDashboardListFilter filter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _Chip(text: filter.dashboardTitle, textTheme: textTheme),
            _Chip(text: filter.statusLabel, textTheme: textTheme),
            if (filter.entity != null)
              _Chip(text: filter.entity!, textTheme: textTheme),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.textTheme});

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final _DashboardListItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor =
        item.status == 'OUT' ? colorScheme.tertiary : colorScheme.secondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          item.invitationId,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            _InfoRow(label: 'Name', value: item.name),
            _InfoRow(label: 'IC/Passport', value: item.icNumber),
            _InfoRow(
              label: 'Status',
              value: item.status,
              valueStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                _InfoRow(label: 'Visit From', value: item.visitFrom),
                _InfoRow(label: 'Visit To', value: item.visitTo),
                _InfoRow(label: 'Department', value: item.department),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardListItem {
  const _DashboardListItem({
    required this.invitationId,
    required this.icNumber,
    required this.name,
    required this.visitFrom,
    required this.visitTo,
    required this.status,
    required this.department,
  });

  final String invitationId;
  final String icNumber;
  final String name;
  final String visitFrom;
  final String visitTo;
  final String status;
  final String department;
}
