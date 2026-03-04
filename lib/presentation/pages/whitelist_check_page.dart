import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/whitelist_search_filter_entity.dart';
import '../../domain/entities/whitelist_search_item_entity.dart';
import '../app/router.dart';
import '../pages/whitelist_detail_page.dart';
import '../state/async_option_helpers.dart';
import '../state/entity_option.dart';
import '../state/reference_providers.dart';
import '../state/whitelist_check_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/info_row.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/searchable_option_sheet.dart';
import '../widgets/whitelist_status_badge.dart';

class WhitelistCheckPage extends ConsumerStatefulWidget {
  const WhitelistCheckPage({super.key, required this.isCheckIn});

  final bool isCheckIn;

  @override
  ConsumerState<WhitelistCheckPage> createState() => _WhitelistCheckPageState();
}

class _WhitelistCheckPageState extends ConsumerState<WhitelistCheckPage> {
  String? _entity;
  String? _status;
  final TextEditingController _vehiclePlateController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  bool _didLoadInitial = false;

  String get _currentType => widget.isCheckIn ? 'I' : 'O';

  String _toDisplayError(Object error, String fallback) {
    final text = error.toString().trim();
    if (text.startsWith('Exception:')) {
      return text.replaceFirst('Exception:', '').trim();
    }
    return text.isEmpty ? fallback : text;
  }

  @override
  void dispose() {
    _vehiclePlateController.dispose();
    _icController.dispose();
    super.dispose();
  }

  void _maybeLoadInitial(List<EntityOption> entityOptions) {
    if (_didLoadInitial) {
      return;
    }

    final defaultEntity = entityOptions
        .map((option) => option.value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (defaultEntity.isEmpty) {
      _didLoadInitial = true;
      ref
          .read(whitelistCheckControllerProvider.notifier)
          .loadInitial(currentType: _currentType, defaultEntity: '');
      return;
    }

    _didLoadInitial = true;
    _entity = defaultEntity;
    ref
        .read(whitelistCheckControllerProvider.notifier)
        .loadInitial(currentType: _currentType, defaultEntity: defaultEntity);
  }

  String? _statusToRequest(String? label) {
    switch (label) {
      case 'Active':
        return 'ACTIVE';
      case 'Inactive':
        return 'INACTIVE';
      default:
        return null;
    }
  }

  Future<void> _requestListing() {
    final entity = _entity?.trim() ?? '';
    if (entity.isEmpty) {
      return Future<void>.value();
    }

    return ref
        .read(whitelistCheckControllerProvider.notifier)
        .applyFilters(
          WhitelistSearchFilterEntity(
            entity: entity,
            currentType: _currentType,
            vehiclePlate: _vehiclePlateController.text.trim(),
            ic: _icController.text.trim(),
            status: _statusToRequest(_status),
          ),
        );
  }

  Future<void> _openFilters() async {
    final defaultEntity = _entity?.trim() ?? '';
    final result = await Navigator.of(context).push<_WhitelistFilterResult>(
      MaterialPageRoute(
        builder: (context) => _WhitelistFilterPage(
          currentType: _currentType,
          defaultEntity: defaultEntity,
          initialEntity: _entity,
          initialVehiclePlate: _vehiclePlateController.text,
          initialIc: _icController.text,
          initialStatus: _status,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _entity = result.entity;
      _status = result.status;
      _vehiclePlateController.text = result.vehiclePlate;
      _icController.text = result.ic;
    });
    _requestListing();
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

    final state = ref.watch(whitelistCheckControllerProvider);
    final showInitialLoader = state.isLoading && !state.hasLoaded;
    final showEmptyState =
        state.hasLoaded && !state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCheckIn ? 'Whitelist Check-In' : 'Whitelist Check-Out',
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showInitialLoader)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            if (entityLoadError != null && !_didLoadInitial)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entityLoadError,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppFilledButton(
                          onPressed: () =>
                              ref.invalidate(entityOptionsProvider),
                          child: const Text('Retry Entities'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (state.errorMessage?.trim().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppFilledButton(
                          onPressed: _requestListing,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: showEmptyState
                  ? const Center(
                      child: Text('No whitelist records to display.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) => _WhitelistCard(
                        item: state.items[index],
                        checkType: _currentType,
                        onOpenDetail: (item) {
                          final entity = item.entity.trim();
                          final vehiclePlate = item.vehiclePlate.trim();
                          if (entity.isEmpty || vehiclePlate.isEmpty) {
                            showAppSnackBar(
                              context,
                              'Missing entity or vehicle plate for detail.',
                            );
                            return;
                          }
                          context.pushNamed(
                            whitelistDetailRouteName,
                            extra: WhitelistDetailRouteArgs(
                              entity: entity,
                              vehiclePlate: vehiclePlate,
                              checkType: _currentType,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WhitelistCard extends StatelessWidget {
  const _WhitelistCard({
    required this.item,
    required this.checkType,
    required this.onOpenDetail,
  });

  final WhitelistSearchItemEntity item;
  final String checkType;
  final ValueChanged<WhitelistSearchItemEntity> onOpenDetail;

  String _displayOrDash(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final isOpenable =
        item.entity.trim().isNotEmpty && item.vehiclePlate.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onOpenDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isOpenable ? 1 : 0.6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _displayOrDash(item.name.isEmpty ? item.ic : item.name),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    WhitelistStatusBadge(statusCode: item.status),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 8),
                InfoRow(
                  label: 'Check Type',
                  value: checkType == 'O' ? 'Out' : 'In',
                ),
                InfoRow(
                  label: 'Vehicle Plate',
                  value: _displayOrDash(item.vehiclePlate),
                ),
                InfoRow(label: 'IC', value: _displayOrDash(item.ic)),
                InfoRow(
                  label: 'View',
                  value: isOpenable ? 'Details' : 'Unavailable',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhitelistFilterResult {
  const _WhitelistFilterResult({
    required this.entity,
    required this.vehiclePlate,
    required this.ic,
    required this.status,
  });

  final String? entity;
  final String vehiclePlate;
  final String ic;
  final String? status;
}

class _WhitelistFilterPage extends ConsumerStatefulWidget {
  const _WhitelistFilterPage({
    required this.currentType,
    required this.defaultEntity,
    required this.initialEntity,
    required this.initialVehiclePlate,
    required this.initialIc,
    required this.initialStatus,
  });

  final String currentType;
  final String defaultEntity;
  final String? initialEntity;
  final String initialVehiclePlate;
  final String initialIc;
  final String? initialStatus;

  @override
  ConsumerState<_WhitelistFilterPage> createState() =>
      _WhitelistFilterPageState();
}

class _WhitelistFilterPageState extends ConsumerState<_WhitelistFilterPage> {
  late final TextEditingController _vehiclePlateController;
  late final TextEditingController _icController;

  String? _entity;
  String? _status;

  @override
  void initState() {
    super.initState();
    _entity = widget.initialEntity?.trim().isNotEmpty == true
        ? widget.initialEntity
        : widget.defaultEntity;
    _status = widget.initialStatus;
    _vehiclePlateController = TextEditingController(
      text: widget.initialVehiclePlate,
    );
    _icController = TextEditingController(text: widget.initialIc);
  }

  @override
  void dispose() {
    _vehiclePlateController.dispose();
    _icController.dispose();
    super.dispose();
  }

  String _toDisplayError(Object error, String fallback) {
    final text = error.toString().trim();
    if (text.startsWith('Exception:')) {
      return text.replaceFirst('Exception:', '').trim();
    }
    return text.isEmpty ? fallback : text;
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

  void _apply() {
    Navigator.of(context).pop(
      _WhitelistFilterResult(
        entity: _entity,
        vehiclePlate: _vehiclePlateController.text,
        ic: _icController.text,
        status: _status,
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _entity = widget.defaultEntity;
      _status = null;
      _vehiclePlateController.clear();
      _icController.clear();
    });
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

    final statusDisplayValue = _status;
    final statusOptions = const <String>['Active', 'Inactive'];

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
                      if (widget.defaultEntity.trim().isEmpty) {
                        return;
                      }
                      setState(() => _entity = widget.defaultEntity);
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
                          : pickedOption.value;
                      setState(() => _entity = selectedValue);
                    },
                  ),
                  LabeledTextInputRow(
                    label: 'Vehicle Plate',
                    controller: _vehiclePlateController,
                    hintText: 'Please input',
                    onChanged: (_) => setState(() {}),
                    suffixIcon: _vehiclePlateController.text.trim().isEmpty
                        ? null
                        : CompactSuffixTapIcon(
                            key: const Key('whitelist-filter-clear-vehicle'),
                            icon: Icons.clear,
                            onTap: () {
                              _vehiclePlateController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                  LabeledTextInputRow(
                    label: 'IC',
                    controller: _icController,
                    hintText: 'Please input',
                    onChanged: (_) => setState(() {}),
                    suffixIcon: _icController.text.trim().isEmpty
                        ? null
                        : CompactSuffixTapIcon(
                            key: const Key('whitelist-filter-clear-ic'),
                            icon: Icons.clear,
                            onTap: () {
                              _icController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                  LabeledSelectRow(
                    label: 'Status',
                    value: statusDisplayValue,
                    placeholder: 'Please select',
                    onClear: _status == null
                        ? null
                        : () => setState(() => _status = null),
                    onTap: () async {
                      final selected = await _pickFilterOption(
                        title: 'Status',
                        options: statusOptions,
                        currentValue: statusDisplayValue,
                      );
                      if (!mounted || selected == null) {
                        return;
                      }
                      setState(() => _status = selected);
                    },
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Current Type: ${widget.currentType == 'I' ? 'I (Check-In)' : 'O (Check-Out)'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
