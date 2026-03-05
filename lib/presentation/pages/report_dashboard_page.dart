import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../app/router.dart';
import '../state/async_option_helpers.dart';
import '../state/entity_option.dart';
import '../state/reference_providers.dart';
import '../state/report_dashboard_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/searchable_option_sheet.dart';
import 'report_dashboard_list_page.dart';

class ReportDashboardPage extends ConsumerStatefulWidget {
  const ReportDashboardPage({super.key});

  @override
  ConsumerState<ReportDashboardPage> createState() =>
      _ReportDashboardPageState();
}

class _ReportDashboardPageState extends ConsumerState<ReportDashboardPage> {
  bool _didLoadInitial = false;

  String _toDisplayError(Object error, String fallback) {
    return toDisplayErrorMessage(error, fallback: fallback);
  }

  void _maybeLoadInitial(List<EntityOption> entityOptions) {
    if (_didLoadInitial) {
      return;
    }

    final defaultEntity = entityOptions
        .map((option) => option.value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    _didLoadInitial = true;

    ref
        .read(reportDashboardControllerProvider.notifier)
        .loadInitial(defaultEntity: defaultEntity);
  }

  Future<void> _openFilters({
    required String defaultEntity,
    required String activeEntity,
  }) async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => _DashboardFilterPage(
          defaultEntity: defaultEntity,
          initialEntity: activeEntity,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    ref.read(reportDashboardControllerProvider.notifier).applyEntity(selected);
  }

  @override
  Widget build(BuildContext context) {
    final entityOptionsAsync = ref.watch(entityOptionsProvider);
    final entityOptions = extractOptions<EntityOption>(entityOptionsAsync);
    final entityLoadError = extractErrorText(
      entityOptionsAsync,
      fallback: 'Failed to load entities. Please try again.',
      errorToText: _toDisplayError,
    );

    if (entityOptionsAsync.hasValue && !_didLoadInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _maybeLoadInitial(entityOptions);
      });
    }

    final state = ref.watch(reportDashboardControllerProvider);
    final showInitialLoader = state.isLoading && !state.hasLoaded;

    final defaultEntity = state.defaultEntity ?? '';
    final activeEntity = state.activeEntity ?? defaultEntity;
    final summary = state.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: showInitialLoader
                ? null
                : () => _openFilters(
                    defaultEntity: defaultEntity,
                    activeEntity: activeEntity,
                  ),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: showInitialLoader
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (entityLoadError != null && !_didLoadInitial)
                  _ErrorCard(
                    message: entityLoadError,
                    buttonLabel: 'Retry Entities',
                    onTap: () => ref.invalidate(entityOptionsProvider),
                  ),
                if (state.errorMessage?.trim().isNotEmpty == true)
                  _ErrorCard(
                    message: state.errorMessage!,
                    buttonLabel: 'Retry',
                    onTap: () {
                      final retryEntity =
                          state.activeEntity ?? state.defaultEntity ?? '';
                      ref
                          .read(reportDashboardControllerProvider.notifier)
                          .applyEntity(retryEntity);
                    },
                  ),
                const SizedBox(height: 8),
                _DashboardSection(
                  title: 'Visitor Dashboard',
                  cards: [
                    _KpiCardData(
                      label: 'Total IN',
                      value: _metricValue(summary?.visitor.totalInRecords),
                      filterValue: 'IN',
                    ),
                    _KpiCardData(
                      label: 'Total OUT',
                      value: _metricValue(summary?.visitor.totalOutRecords),
                      filterValue: 'OUT',
                    ),
                    _KpiCardData(
                      label: 'Currently Inside',
                      value: _metricValue(summary?.visitor.stillInCount),
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
                        entity: activeEntity.isEmpty ? null : activeEntity,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _DashboardSection(
                  title: 'Contractor Dashboard',
                  cards: [
                    _KpiCardData(
                      label: 'Total IN',
                      value: _metricValue(summary?.contractor.totalInRecords),
                      filterValue: 'IN',
                    ),
                    _KpiCardData(
                      label: 'Total OUT',
                      value: _metricValue(summary?.contractor.totalOutRecords),
                      filterValue: 'OUT',
                    ),
                    _KpiCardData(
                      label: 'Currently Inside',
                      value: _metricValue(summary?.contractor.stillInCount),
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
                        entity: activeEntity.isEmpty ? null : activeEntity,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _DashboardSection(
                  title: 'Whitelist Dashboard',
                  cards: [
                    _KpiCardData(
                      label: 'Total IN',
                      value: _metricValue(summary?.whitelist.totalInRecords),
                      filterValue: 'IN',
                    ),
                    _KpiCardData(
                      label: 'Total OUT',
                      value: _metricValue(summary?.whitelist.totalOutRecords),
                      filterValue: 'OUT',
                    ),
                    _KpiCardData(
                      label: 'Currently Inside',
                      value: _metricValue(summary?.whitelist.stillInCount),
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
                        entity: activeEntity.isEmpty ? null : activeEntity,
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  static String _metricValue(int? value) => (value ?? 0).toString();
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.buttonLabel,
    required this.onTap,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              AppFilledButton(onPressed: onTap, child: Text(buttonLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardFilterPage extends ConsumerStatefulWidget {
  const _DashboardFilterPage({
    required this.defaultEntity,
    required this.initialEntity,
  });

  final String defaultEntity;
  final String initialEntity;

  @override
  ConsumerState<_DashboardFilterPage> createState() =>
      _DashboardFilterPageState();
}

class _DashboardFilterPageState extends ConsumerState<_DashboardFilterPage> {
  String? _entity;

  @override
  void initState() {
    super.initState();
    _entity = widget.initialEntity.trim().isNotEmpty
        ? widget.initialEntity.trim()
        : widget.defaultEntity.trim();
  }

  String _toDisplayError(Object error, String fallback) {
    return toDisplayErrorMessage(error, fallback: fallback);
  }

  Future<String?> _pickFilterOption({
    required String title,
    required List<String> options,
    String? currentValue,
  }) {
    return showSearchableOptionSheet(
      context: context,
      title: title,
      options: options,
      currentValue: currentValue,
    );
  }

  void _clearAll() {
    setState(() {
      _entity = widget.defaultEntity.trim();
    });
  }

  void _apply() {
    final selected = (_entity ?? widget.defaultEntity).trim();
    if (selected.isEmpty) {
      Navigator.of(context).pop<String>(widget.defaultEntity.trim());
      return;
    }
    Navigator.of(context).pop<String>(selected);
  }

  @override
  Widget build(BuildContext context) {
    final entityOptionsAsync = ref.watch(entityOptionsProvider);
    final entityOptions = extractOptions<EntityOption>(entityOptionsAsync);
    final entityDisplayValue = findDisplayLabel<EntityOption>(
      options: entityOptions,
      selectedCode: _entity,
      valueOf: (option) => option.value,
      labelOf: (option) => option.label,
    );
    final entityLoadError = extractErrorText(
      entityOptionsAsync,
      fallback: 'Failed to load entities. Tap to retry.',
      errorToText: _toDisplayError,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _clearAll,
            child: const Text('Clear All'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: AppFilledButton(onPressed: _apply, child: const Text('Apply')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  LabeledSelectRow(
                    label: 'Entity',
                    isRequired: true,
                    value: entityDisplayValue,
                    placeholder: entityOptionsAsync.isLoading
                        ? 'Loading...'
                        : 'Please select',
                    helperText: entityLoadError,
                    enabled: !entityOptionsAsync.isLoading,
                    onClear: () {
                      final fallback = widget.defaultEntity.trim();
                      if (fallback.isEmpty) {
                        return;
                      }
                      setState(() => _entity = fallback);
                    },
                    onTap: () async {
                      if (entityOptionsAsync.hasError) {
                        ref.invalidate(entityOptionsProvider);
                        return;
                      }
                      if (entityOptions.isEmpty) {
                        return;
                      }

                      final selected = await _pickFilterOption(
                        title: 'Entity',
                        options: entityOptions
                            .map((option) => option.label)
                            .toList(growable: false),
                        currentValue: entityDisplayValue,
                      );
                      if (!mounted || selected == null) {
                        return;
                      }

                      final pickedOption = entityOptions.firstWhere(
                        (option) => option.label == selected,
                        orElse: () => const EntityOption(value: '', label: ''),
                      );
                      final selectedValue = pickedOption.value.trim().isEmpty
                          ? null
                          : pickedOption.value.trim();
                      setState(() => _entity = selectedValue);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
