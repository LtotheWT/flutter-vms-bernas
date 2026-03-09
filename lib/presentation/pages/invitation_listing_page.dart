import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/invitation_list_item_entity.dart';
import '../../domain/entities/invitation_listing_filter_entity.dart';
import '../app/router.dart';
import '../state/async_option_helpers.dart';
import '../state/department_option.dart';
import '../state/entity_option.dart';
import '../state/invitation_listing_providers.dart';
import '../state/option_label_formatters.dart';
import '../state/reference_providers.dart';
import '../state/site_option.dart';
import '../state/visitor_type_option.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/info_row.dart';
import '../widgets/invitation_status_badge.dart';
import '../widgets/searchable_option_sheet.dart';

String _todayDateText() {
  final now = DateTime.now();
  final year = now.year.toString().padLeft(4, '0');
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

class InvitationListingPage extends ConsumerStatefulWidget {
  const InvitationListingPage({super.key});

  @override
  ConsumerState<InvitationListingPage> createState() =>
      _InvitationListingPageState();
}

class _InvitationListingPageState extends ConsumerState<InvitationListingPage> {
  final _invitationIdController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _entity;
  String? _site;
  String? _department;
  String? _visitorType;
  String? _status;
  bool _upcomingOnly = false;
  final List<InvitationListItemEntity> _items = [];
  bool _showBackToTop = false;
  late final ProviderSubscription<InvitationListingState> _listingSubscription;

  @override
  void initState() {
    super.initState();
    final today = _todayDateText();
    _dateFromController.text = today;
    _dateToController.text = today;
    _scrollController.addListener(_onScroll);
    _listingSubscription = ref.listenManual<InvitationListingState>(
      invitationListingControllerProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }
        final hasItemChanges = previous == null || previous.items != next.items;
        if (!hasItemChanges) {
          return;
        }

        setState(() {
          _items
            ..clear()
            ..addAll(next.items);
        });
      },
      fireImmediately: true,
    );
    Future<void>.microtask(
      () =>
          ref.read(invitationListingControllerProvider.notifier).loadInitial(),
    );
  }

  @override
  void dispose() {
    _listingSubscription.close();
    _invitationIdController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    final today = _todayDateText();
    _invitationIdController.clear();
    _dateFromController.text = today;
    _dateToController.text = today;
    setState(() {
      _entity = null;
      _site = null;
      _department = null;
      _visitorType = null;
      _status = null;
      _upcomingOnly = false;
    });
    _requestListing();
  }

  void _onScroll() {
    final offset = _scrollController.position.pixels;
    final shouldShowTop = offset > 400;
    if (shouldShowTop != _showBackToTop) {
      setState(() => _showBackToTop = shouldShowTop);
    }
  }

  Future<void> _requestListing() {
    return ref
        .read(invitationListingControllerProvider.notifier)
        .applyFilters(
          InvitationListingFilterEntity(
            entity: _entity,
            site: _site,
            department: _department,
            visitorType: _visitorType,
            statusCode: _statusToApiCode(_status),
            invitationId: _invitationIdController.text.trim(),
            visitDateFrom: _dateFromController.text.trim(),
            visitDateTo: _dateToController.text.trim(),
            upcomingOnly: _upcomingOnly,
          ),
        );
  }

  String? _statusToApiCode(String? status) {
    switch (status) {
      case 'New':
        return 'NEW';
      case 'Approved':
        return 'APPROVED';
      case 'Rejected':
        return 'REJECTED';
      default:
        return null;
    }
  }

  String _visitorTypeDisplay(String value) {
    final parts = value.split('_');
    return parts.length == 2 && parts.first.trim().isNotEmpty
        ? parts.last.trim()
        : value;
  }

  Future<void> _confirmDelete(InvitationListItemEntity item) async {
    final invitationId = item.invitationId.trim();
    if (invitationId.isEmpty) {
      showAppSnackBar(
        context,
        'Invitation ID is required to delete invitation.',
      );
      return;
    }
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete invitation?'),
        content: Text('You are about to delete invitation $invitationId.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          AppFilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final result = await ref
        .read(invitationListingControllerProvider.notifier)
        .deleteInvitation(invitationId: invitationId);
    if (!mounted) {
      return;
    }
    final message = result.message.trim().isEmpty
        ? (result.status
              ? 'Invitation deleted successfully.'
              : 'Failed to delete invitation. Please try again.')
        : result.message;
    showAppSnackBar(context, message);
  }

  Future<void> _openFilters() async {
    final result = await Navigator.of(context).push<_InvitationFilterResult>(
      MaterialPageRoute(
        builder: (context) => _InvitationFilterPage(
          initialEntity: _entity,
          initialSite: _site,
          initialDepartment: _department,
          initialVisitorType: _visitorType,
          initialStatus: _status,
          initialInvitationId: _invitationIdController.text,
          initialDateFrom: _dateFromController.text,
          initialDateTo: _dateToController.text,
          initialUpcomingOnly: _upcomingOnly,
        ),
      ),
    );

    if (!mounted || result == null) return;

    if (result.clearRequested) {
      _clearFilters();
      return;
    }

    setState(() {
      _entity = result.entity;
      _site = result.site;
      _department = result.department;
      _visitorType = result.visitorType;
      _status = result.status;
      _upcomingOnly = result.upcomingOnly;
      _invitationIdController.text = result.invitationId;
      _dateFromController.text = result.dateFrom;
      _dateToController.text = result.dateTo;
    });
    _requestListing();
  }

  @override
  Widget build(BuildContext context) {
    final listingState = ref.watch(invitationListingControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final showInitialLoader =
        listingState.isLoading && !listingState.hasLoaded && _items.isEmpty;
    final showEmptyState =
        !listingState.isLoading && listingState.hasLoaded && _items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation Listing'),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
          IconButton(
            onPressed: () => context.push(invitationAddRoutePath),
            icon: const Icon(Icons.add),
            tooltip: 'New',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _requestListing,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            if (showInitialLoader)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (listingState.errorMessage != null &&
                listingState.errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Card(
                  color: colorScheme.errorContainer.withValues(alpha: 0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listingState.errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const SizedBox(height: 10),
                        AppOutlinedButton(
                          onPressed: _requestListing,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 4),
            Text(
              'Results',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showEmptyState)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'No records to display.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 12),
            for (final item in _items)
              _InvitationCard(
                item: item,
                visitorTypeLabel: _visitorTypeDisplay(item.visitorType),
                isDeleting:
                    listingState.deletingInvitationId == item.invitationId,
                onDeleteTap: () => _confirmDelete(item),
              ),
          ],
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}

class _InvitationFilterResult {
  const _InvitationFilterResult({
    required this.entity,
    required this.site,
    required this.department,
    required this.visitorType,
    required this.status,
    required this.invitationId,
    required this.dateFrom,
    required this.dateTo,
    required this.upcomingOnly,
    this.clearRequested = false,
  });

  final String? entity;
  final String? site;
  final String? department;
  final String? visitorType;
  final String? status;
  final String invitationId;
  final String dateFrom;
  final String dateTo;
  final bool upcomingOnly;
  final bool clearRequested;
}

class _InvitationFilterPage extends ConsumerStatefulWidget {
  const _InvitationFilterPage({
    required this.initialEntity,
    required this.initialSite,
    required this.initialDepartment,
    required this.initialVisitorType,
    required this.initialStatus,
    required this.initialInvitationId,
    required this.initialDateFrom,
    required this.initialDateTo,
    required this.initialUpcomingOnly,
  });

  final String? initialEntity;
  final String? initialSite;
  final String? initialDepartment;
  final String? initialVisitorType;
  final String? initialStatus;
  final String initialInvitationId;
  final String initialDateFrom;
  final String initialDateTo;
  final bool initialUpcomingOnly;

  @override
  ConsumerState<_InvitationFilterPage> createState() =>
      _InvitationFilterPageState();
}

class _InvitationFilterPageState extends ConsumerState<_InvitationFilterPage> {
  late final TextEditingController _invitationIdController;
  late final TextEditingController _dateFromController;
  late final TextEditingController _dateToController;

  String? _entity;
  String? _site;
  String? _department;
  String? _visitorType;
  String? _status;
  bool _upcomingOnly = false;

  @override
  void initState() {
    super.initState();
    _entity = widget.initialEntity;
    _site = widget.initialSite;
    _department = widget.initialDepartment;
    _visitorType = widget.initialVisitorType;
    _status = widget.initialStatus;
    _upcomingOnly = widget.initialUpcomingOnly;
    _invitationIdController = TextEditingController(
      text: widget.initialInvitationId,
    );
    _dateFromController = TextEditingController(
      text: widget.initialDateFrom.trim().isEmpty
          ? _todayDateText()
          : widget.initialDateFrom,
    );
    _dateToController = TextEditingController(
      text: widget.initialDateTo.trim().isEmpty
          ? _todayDateText()
          : widget.initialDateTo,
    );
  }

  @override
  void dispose() {
    _invitationIdController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required TextEditingController controller}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    controller.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() {});
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
      _InvitationFilterResult(
        entity: _entity,
        site: _site,
        department: _department,
        visitorType: _visitorType,
        status: _status,
        invitationId: _invitationIdController.text,
        dateFrom: _dateFromController.text,
        dateTo: _dateToController.text,
        upcomingOnly: _upcomingOnly,
      ),
    );
  }

  void _clearAll() {
    final today = _todayDateText();
    Navigator.of(context).pop(
      _InvitationFilterResult(
        entity: null,
        site: null,
        department: null,
        visitorType: null,
        status: null,
        invitationId: '',
        dateFrom: today,
        dateTo: today,
        upcomingOnly: false,
        clearRequested: true,
      ),
    );
  }

  String _toDisplayError(Object error, String fallback) {
    return toDisplayErrorMessage(error, fallback: fallback);
  }

  @override
  Widget build(BuildContext context) {
    final entityOptionsAsync = ref.watch(entityOptionsProvider);
    final entityOptions = extractOptions<EntityOption>(entityOptionsAsync);
    final entityDisplayValue = findDisplayLabel<EntityOption>(
      options: entityOptions,
      selectedCode: _entity,
      valueOf: (option) => option.value,
      labelOf: (option) => labelOrBlank(option.label),
    );
    final entityLoadError = extractErrorText(
      entityOptionsAsync,
      fallback: 'Failed to load entities. Tap to retry.',
      errorToText: _toDisplayError,
    );

    final siteOptionsAsync = ref.watch(siteOptionsProvider(_entity));
    final siteOptions = extractOptions<SiteOption>(siteOptionsAsync);
    final siteDisplayValue = findDisplayLabel<SiteOption>(
      options: siteOptions,
      selectedCode: _site,
      valueOf: (option) => option.value,
      labelOf: (option) => siteLabel(value: option.value, label: option.label),
    );
    final siteLoadError = extractErrorText(
      siteOptionsAsync,
      fallback: 'Failed to load sites. Tap to retry.',
      errorToText: _toDisplayError,
    );
    final sitePickState = pickState(
      hasParent: _entity != null,
      asyncValue: siteOptionsAsync,
    );
    final canRetrySite = sitePickState.canRetry;
    final canPickSite = sitePickState.canPick;
    final enableSiteField = sitePickState.enabled;

    final departmentOptionsAsync = ref.watch(
      departmentOptionsProvider(_entity),
    );
    final departmentOptions = extractOptions<DepartmentOption>(
      departmentOptionsAsync,
    );
    final departmentDisplayValue = findDisplayLabel<DepartmentOption>(
      options: departmentOptions,
      selectedCode: _department,
      valueOf: (option) => option.value,
      labelOf: (option) => labelOrBlank(option.label),
    );
    final departmentLoadError = extractErrorText(
      departmentOptionsAsync,
      fallback: 'Failed to load departments. Tap to retry.',
      errorToText: _toDisplayError,
    );
    final departmentPickState = pickState(
      hasParent: _entity != null,
      asyncValue: departmentOptionsAsync,
    );
    final canRetryDepartment = departmentPickState.canRetry;
    final canPickDepartment = departmentPickState.canPick;
    final enableDepartmentField = departmentPickState.enabled;

    final visitorTypeOptionsAsync = ref.watch(visitorTypeOptionsProvider);
    final visitorTypeOptions = extractOptions<VisitorTypeOption>(
      visitorTypeOptionsAsync,
    );
    final visitorTypeDisplayValue = findDisplayLabel<VisitorTypeOption>(
      options: visitorTypeOptions,
      selectedCode: _visitorType,
      valueOf: (option) => option.value,
      labelOf: (option) =>
          visitorTypeLabel(value: option.value, label: option.label),
    );
    final visitorTypeLoadError = extractErrorText(
      visitorTypeOptionsAsync,
      fallback: 'Failed to load visitor types. Tap to retry.',
      errorToText: _toDisplayError,
    );
    final canPickVisitorType = pickState(
      hasParent: true,
      asyncValue: visitorTypeOptionsAsync,
    ).canPick;

    if (_entity != null &&
        siteOptionsAsync.hasValue &&
        shouldClearStaleSelection<SiteOption>(
          selectedValue: _site,
          options: siteOptions,
          valueOf: (option) => option.value,
        )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _site = null);
      });
    }
    if (_entity != null &&
        departmentOptionsAsync.hasValue &&
        shouldClearStaleSelection<DepartmentOption>(
          selectedValue: _department,
          options: departmentOptions,
          valueOf: (option) => option.value,
        )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _department = null);
      });
    }
    if (visitorTypeOptionsAsync.hasValue &&
        shouldClearStaleSelection<VisitorTypeOption>(
          selectedValue: _visitorType,
          options: visitorTypeOptions,
          valueOf: (option) => option.value,
        )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _visitorType = null);
      });
    }

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
                    onClear: _entity == null
                        ? null
                        : () {
                            setState(() {
                              _entity = null;
                              _site = null;
                              _department = null;
                            });
                          },
                    onTap: () async {
                      if (entityOptionsAsync.hasError) {
                        ref.invalidate(entityOptionsProvider);
                        return;
                      }
                      if (entityOptions.isEmpty) return;
                      final selected = await _pickFilterOption(
                        title: 'Entity',
                        options: entityOptions
                            .map((option) => labelOrBlank(option.label))
                            .toList(growable: false),
                        currentValue: entityDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = entityOptions.firstWhere(
                        (option) => labelOrBlank(option.label) == selected,
                        orElse: () => const EntityOption(value: '', label: ''),
                      );
                      final selectedValue = pickedOption.value.trim().isEmpty
                          ? null
                          : pickedOption.value;

                      setState(() {
                        _entity = selectedValue;
                        _site = null;
                        _department = null;
                      });
                    },
                  ),
                  LabeledSelectRow(
                    label: 'Site',
                    isRequired: true,
                    value: siteDisplayValue,
                    placeholder: siteOptionsAsync.isLoading
                        ? 'Loading...'
                        : _entity == null
                        ? 'Select entity first'
                        : 'Please select',
                    helperText: siteLoadError,
                    enabled: enableSiteField,
                    onClear: _site == null
                        ? null
                        : () => setState(() => _site = null),
                    onTap: () async {
                      if (_entity == null) return;
                      if (canRetrySite) {
                        ref.invalidate(siteOptionsProvider(_entity));
                        return;
                      }
                      if (!canPickSite || siteOptions.isEmpty) return;

                      final selected = await _pickFilterOption(
                        title: 'Site',
                        options: siteOptions
                            .map(
                              (option) => siteLabel(
                                value: option.value,
                                label: option.label,
                              ),
                            )
                            .toList(growable: false),
                        currentValue: siteDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = siteOptions.firstWhere(
                        (option) =>
                            siteLabel(
                              value: option.value,
                              label: option.label,
                            ) ==
                            selected,
                        orElse: () => const SiteOption(value: '', label: ''),
                      );
                      final selectedValue = pickedOption.value.trim().isEmpty
                          ? null
                          : pickedOption.value;

                      setState(() => _site = selectedValue);
                    },
                  ),
                  LabeledSelectRow(
                    label: 'Department',
                    isRequired: true,
                    value: departmentDisplayValue,
                    placeholder: departmentOptionsAsync.isLoading
                        ? 'Loading...'
                        : _entity == null
                        ? 'Select entity first'
                        : 'Please select',
                    helperText: departmentLoadError,
                    enabled: enableDepartmentField,
                    onClear: _department == null
                        ? null
                        : () => setState(() => _department = null),
                    onTap: () async {
                      if (canRetryDepartment) {
                        ref.invalidate(departmentOptionsProvider(_entity));
                        return;
                      }
                      if (!canPickDepartment || departmentOptions.isEmpty) {
                        return;
                      }

                      final selected = await _pickFilterOption(
                        title: 'Department',
                        options: departmentOptions
                            .map((option) => labelOrBlank(option.label))
                            .toList(growable: false),
                        currentValue: departmentDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = departmentOptions.firstWhere(
                        (option) => labelOrBlank(option.label) == selected,
                        orElse: () =>
                            const DepartmentOption(value: '', label: ''),
                      );
                      final selectedValue = pickedOption.value.trim().isEmpty
                          ? null
                          : pickedOption.value;

                      setState(() => _department = selectedValue);
                    },
                  ),
                  LabeledSelectRow(
                    label: 'Visitor Type',
                    value: visitorTypeDisplayValue,
                    placeholder: visitorTypeOptionsAsync.isLoading
                        ? 'Loading...'
                        : 'Please select',
                    helperText: visitorTypeLoadError,
                    enabled: !visitorTypeOptionsAsync.isLoading,
                    onClear: _visitorType == null
                        ? null
                        : () => setState(() => _visitorType = null),
                    onTap: () async {
                      if (visitorTypeOptionsAsync.hasError) {
                        ref.invalidate(visitorTypeOptionsProvider);
                        return;
                      }
                      if (!canPickVisitorType || visitorTypeOptions.isEmpty) {
                        return;
                      }

                      final selected = await _pickFilterOption(
                        title: 'Visitor Type',
                        options: visitorTypeOptions
                            .map(
                              (option) => visitorTypeLabel(
                                value: option.value,
                                label: option.label,
                              ),
                            )
                            .toList(growable: false),
                        currentValue: visitorTypeDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = visitorTypeOptions.firstWhere(
                        (option) =>
                            visitorTypeLabel(
                              value: option.value,
                              label: option.label,
                            ) ==
                            selected,
                        orElse: () =>
                            const VisitorTypeOption(value: '', label: ''),
                      );
                      final selectedValue = pickedOption.value.trim().isEmpty
                          ? null
                          : pickedOption.value;

                      setState(() => _visitorType = selectedValue);
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LabeledFieldLabel(label: 'Invitation ID'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _invitationIdController,
                              onChanged: (_) => setState(() {}),
                              onTapOutside: (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              style: Theme.of(context).textTheme.titleMedium,
                              decoration: InputDecoration(
                                hintText: 'Please input',
                                hintStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_invitationIdController.text.trim().isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _invitationIdController.clear();
                                setState(() {});
                              },
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: Icon(Icons.clear, size: 18),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const FormRowDivider(),
                      const SizedBox(height: 8),
                    ],
                  ),
                  LabeledSelectRow(
                    label: 'Visit Date From',
                    value: _dateFromController.text.isEmpty
                        ? null
                        : _dateFromController.text,
                    placeholder: 'Please select',
                    onClear: _dateFromController.text.trim().isEmpty
                        ? null
                        : () {
                            _dateFromController.clear();
                            setState(() {});
                          },
                    onTap: () => _pickDate(controller: _dateFromController),
                  ),
                  LabeledSelectRow(
                    label: 'Visit Date To',
                    value: _dateToController.text.isEmpty
                        ? null
                        : _dateToController.text,
                    placeholder: 'Please select',
                    onClear: _dateToController.text.trim().isEmpty
                        ? null
                        : () {
                            _dateToController.clear();
                            setState(() {});
                          },
                    onTap: () => _pickDate(controller: _dateToController),
                  ),
                  LabeledSelectRow(
                    label: 'Status',
                    value: _status,
                    placeholder: 'Please select',
                    onClear: _status == null
                        ? null
                        : () => setState(() => _status = null),
                    onTap: () async {
                      final selected = await _pickFilterOption(
                        title: 'Status',
                        options: const ['New', 'Approved', 'Rejected'],
                        currentValue: _status,
                      );
                      if (!mounted || selected == null) return;
                      setState(() => _status = selected);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _upcomingOnly,
                    title: const Text('Upcoming Visitor'),
                    secondary: _upcomingOnly
                        ? IconButton(
                            onPressed: () =>
                                setState(() => _upcomingOnly = false),
                            tooltip: 'Clear',
                            icon: const Icon(Icons.clear, size: 18),
                          )
                        : null,
                    onChanged: (value) => setState(() => _upcomingOnly = value),
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

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.item,
    required this.visitorTypeLabel,
    required this.isDeleting,
    required this.onDeleteTap,
  });

  final InvitationListItemEntity item;
  final String visitorTypeLabel;
  final bool isDeleting;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.invitationId,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            InvitationStatusBadge(statusCode: item.statusCode),
            const SizedBox(width: 8),
            GestureDetector(
              key: Key('invitation-delete-${item.invitationId}'),
              onTap: isDeleting ? null : onDeleteTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isDeleting ? Icons.hourglass_top : Icons.delete_outline,
                  color: colorScheme.error,
                  // size: 18,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(item.purpose, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '${item.visitDateFrom} ${item.visitTimeFrom} -> ${item.visitDateTo} ${item.visitTimeTo}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        children: [
          InfoRow(label: 'Entity', value: item.entity),
          InfoRow(label: 'Site', value: item.site),
          InfoRow(label: 'Department', value: item.department),
          InfoRow(label: 'Invite By', value: item.inviteBy),
          InfoRow(label: 'Visitor Type', value: visitorTypeLabel),
          InfoRow(label: 'Company', value: item.company),
          InfoRow(label: 'Vehicle Plate', value: item.vehiclePlateNumber),
          InfoRow(label: 'Created By', value: item.createdBy),
          InfoRow(label: 'Create Date', value: item.createDate),
          InfoRow(label: 'Update Date', value: item.updateDate),
          InfoRow(label: 'Update By', value: item.updateBy),
        ],
      ),
    );
  }
}
