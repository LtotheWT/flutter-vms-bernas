import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../widgets/app_dropdown_form_field.dart';
import '../widgets/app_filled_button.dart';
import 'report_dashboard_list_page.dart';

class ReportDashboardPage extends StatefulWidget {
  const ReportDashboardPage({super.key});

  @override
  State<ReportDashboardPage> createState() => _ReportDashboardPageState();
}

class _ReportDashboardPageState extends State<ReportDashboardPage> {
  String? _entity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _FilterBar(
            entity: _entity,
            onEntityChanged: (value) => setState(() => _entity = value),
            onSearch: () {},
          ),
          const SizedBox(height: 16),
          _DashboardSection(
            title: 'Visitor Dashboard',
            cards: [
              _KpiCardData(label: 'Total IN', value: '801', filterValue: 'IN'),
              _KpiCardData(
                label: 'Total OUT',
                value: '649',
                filterValue: 'OUT',
              ),
              _KpiCardData(
                label: 'Currently Inside',
                value: '152',
                filterValue: 'STILL_IN',
              ),
            ],
            onCardTap: (filterValue, label) {
              context.push(
                reportDashboardListRoutePath,
                extra: ReportDashboardListFilter(
                  dashboardTitle: 'Visitor Dashboard',
                  listTitle: 'Visitor Activity',
                  status: filterValue,
                  statusLabel: label,
                  entity: _entity,
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          _DashboardSection(
            title: 'Contractor Dashboard',
            cards: [
              _KpiCardData(label: 'Total IN', value: '19', filterValue: 'IN'),
              _KpiCardData(label: 'Total OUT', value: '18', filterValue: 'OUT'),
              _KpiCardData(
                label: 'Currently Inside',
                value: '1',
                filterValue: 'STILL_IN',
              ),
            ],
            onCardTap: (filterValue, label) {
              context.push(
                reportDashboardListRoutePath,
                extra: ReportDashboardListFilter(
                  dashboardTitle: 'Contractor Dashboard',
                  listTitle: 'Contractor Activity',
                  status: filterValue,
                  statusLabel: label,
                  entity: _entity,
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          _DashboardSection(
            title: 'Whitelist Dashboard',
            cards: [
              _KpiCardData(label: 'Total IN', value: '11', filterValue: 'IN'),
              _KpiCardData(label: 'Total OUT', value: '9', filterValue: 'OUT'),
              _KpiCardData(
                label: 'Currently Inside',
                value: '2',
                filterValue: 'STILL_IN',
              ),
            ],
            onCardTap: (filterValue, label) {
              context.push(
                reportDashboardListRoutePath,
                extra: ReportDashboardListFilter(
                  dashboardTitle: 'Whitelist Dashboard',
                  listTitle: 'Whitelist Activity',
                  status: filterValue,
                  statusLabel: label,
                  entity: _entity,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.entity,
    required this.onEntityChanged,
    required this.onSearch,
  });

  final String? entity;
  final ValueChanged<String?> onEntityChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        final children = [
          AppDropdownFormField<String>(
            value: entity,
            label: 'Entity',
            items: [
              AppDropdownMenuItem(
                value: 'AGYTEK - Agytek1231',
                label: 'AGYTEK - Agytek1231',
              ),
            ],
            onChanged: onEntityChanged,
          ),
          AppFilledButton(onPressed: onSearch, child: const Text('Search')),
        ];

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [children[0], const SizedBox(height: 12), children[1]],
          );
        }

        return Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 12),
            children[1],
          ],
        );
      },
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.cards,
    required this.onCardTap,
  });

  final String title;
  final List<_KpiCardData> cards;
  final void Function(String value, String label) onCardTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  data: cards[i],
                  onTap: () => onCardTap(cards[i].filterValue, cards[i].label),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _KpiCardData {
  const _KpiCardData({
    required this.label,
    required this.value,
    required this.filterValue,
  });

  final String label;
  final String value;
  final String filterValue;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data, required this.onTap});

  final _KpiCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    data.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
