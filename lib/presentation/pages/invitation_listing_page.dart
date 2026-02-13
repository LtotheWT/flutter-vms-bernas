import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/department_option.dart';
import '../state/entity_option.dart';
import '../state/reference_providers.dart';
import '../state/site_option.dart';
import '../state/visitor_type_option.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/info_row.dart';
import '../widgets/searchable_option_sheet.dart';

class InvitationListingPage extends StatefulWidget {
  const InvitationListingPage({super.key});

  @override
  State<InvitationListingPage> createState() => _InvitationListingPageState();
}

class _InvitationListingPageState extends State<InvitationListingPage> {
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
  final Set<String> _selectedIds = <String>{};
  final List<_InvitationItem> _allItems = [];
  final List<_InvitationItem> _visibleItems = [];
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _showBackToTop = false;
  bool _showActionBar = true;

  @override
  void initState() {
    super.initState();
    _seedMockItems();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _invitationIdController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _invitationIdController.clear();
    _dateFromController.clear();
    _dateToController.clear();
    setState(() {
      _entity = null;
      _site = null;
      _department = null;
      _visitorType = null;
      _status = null;
      _upcomingOnly = false;
    });
  }

  void _seedMockItems() {
    final base = [
      _InvitationItem(
        invitationId: 'IV20251200074',
        entity: 'AGYTEK',
        site: 'FACTORY1 T',
        department: 'ADMIN CENTER',
        personToVisit: 'Suraya',
        createdBy: 'admin',
        visitorType: 'Visitor',
        company: 'JOHNHANSON LIMITED',
        vehiclePlateNumber: 'WSD 011234',
        status: 'Arrived',
        purpose: 'Meeting',
        visitDateFrom: '15/12/2025',
        visitTimeFrom: '00:00 AM',
        visitDateTo: '31/01/2026',
        visitTimeTo: '20:00 PM',
        createDate: '30/12/2025 4:49:37 PM',
        updateDate: '-',
        updateBy: '-',
      ),
      _InvitationItem(
        invitationId: 'IV20251200075',
        entity: 'AGYTEK',
        site: 'FACTORY1 T',
        department: 'OPERATIONS',
        personToVisit: 'Ryan',
        createdBy: 'admin',
        visitorType: 'Contractor',
        company: 'MEGATECH SERVICES',
        vehiclePlateNumber: 'VBA 8821',
        status: 'Approved',
        purpose: 'Maintenance',
        visitDateFrom: '31/01/2026',
        visitTimeFrom: '09:00 AM',
        visitDateTo: '31/01/2026',
        visitTimeTo: '05:00 PM',
        createDate: '30/01/2026 10:12:09 AM',
        updateDate: '30/01/2026 11:05:41 AM',
        updateBy: 'admin',
      ),
      _InvitationItem(
        invitationId: 'IV20251200076',
        entity: 'AGYTEK',
        site: 'FACTORY1 T',
        department: 'ADMIN CENTER',
        personToVisit: 'Aisha',
        createdBy: 'admin',
        visitorType: 'Visitor',
        company: 'NORTHFIELD TRADING',
        vehiclePlateNumber: 'JTP 2290',
        status: 'New',
        purpose: 'Interview',
        visitDateFrom: '02/02/2026',
        visitTimeFrom: '02:30 PM',
        visitDateTo: '02/02/2026',
        visitTimeTo: '04:00 PM',
        createDate: '31/01/2026 08:15:12 AM',
        updateDate: '-',
        updateBy: '-',
      ),
    ];

    for (var i = 0; i < 34; i++) {
      final template = base[i % base.length];
      _allItems.add(
        template.copyWith(
          invitationId: 'IV20251200${100 + i}',
          company: '${template.company} ${i + 1}',
          createDate: '31/01/2026 09:${(i % 60).toString().padLeft(2, '0')} AM',
        ),
      );
    }
  }

  void _onScroll() {
    final offset = _scrollController.position.pixels;
    if (offset > _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
    final shouldShowTop = offset > 400;
    if (shouldShowTop != _showBackToTop) {
      setState(() => _showBackToTop = shouldShowTop);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) {
      return;
    }
    setState(() => _isLoadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final nextIndex = _visibleItems.length;
    final nextItems = _allItems
        .skip(nextIndex)
        .take(_pageSize)
        .toList(growable: false);
    setState(() {
      _visibleItems.addAll(nextItems);
      _isLoadingMore = false;
      if (_visibleItems.length >= _allItems.length) {
        _hasMore = false;
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIds.isEmpty) {
      return;
    }
    _confirmDelete();
  }

  Future<void> _confirmDelete() async {
    final count = _selectedIds.length;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete invitations?'),
        content: Text('You are about to delete $count invitation(s).'),
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

    if (shouldDelete ?? false) {
      setState(() {
        _allItems.removeWhere(
          (item) => _selectedIds.contains(item.invitationId),
        );
        _visibleItems.removeWhere(
          (item) => _selectedIds.contains(item.invitationId),
        );
        _selectedIds.clear();
        if (_visibleItems.length < _pageSize && _hasMore) {
          _loadMore();
        }
      });
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            onPressed: () {},
            icon: const Icon(Icons.add),
            tooltip: 'New',
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showActionBar
                ? Padding(
                    key: const ValueKey('select-bar'),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            value:
                                _selectedIds.length == _visibleItems.length &&
                                _visibleItems.isNotEmpty,
                            onChanged: _visibleItems.isEmpty
                                ? null
                                : (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedIds.addAll(
                                          _visibleItems.map(
                                            (item) => item.invitationId,
                                          ),
                                        );
                                      } else {
                                        _selectedIds.clear();
                                      }
                                    });
                                  },
                            title: Text(
                              'Select all (${_selectedIds.length}/${_visibleItems.length})',
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppOutlinedButtonIcon(
                          onPressed: _selectedIds.isEmpty
                              ? null
                              : _deleteSelected,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(
                            _selectedIds.isEmpty
                                ? 'Delete'
                                : 'Delete (${_selectedIds.length})',
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('select-bar-hidden')),
          ),
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                final direction = notification.direction;
                if (direction == ScrollDirection.forward && !_showActionBar) {
                  setState(() => _showActionBar = true);
                } else if (direction == ScrollDirection.reverse &&
                    _showActionBar) {
                  setState(() => _showActionBar = false);
                }
                return false;
              },
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Results',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in _visibleItems)
                    _InvitationCard(
                      item: item,
                      selected: _selectedIds.contains(item.invitationId),
                      onSelected: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedIds.add(item.invitationId);
                          } else {
                            _selectedIds.remove(item.invitationId);
                          }
                        });
                      },
                    ),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!_hasMore && _visibleItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No more results.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
    _dateFromController = TextEditingController(text: widget.initialDateFrom);
    _dateToController = TextEditingController(text: widget.initialDateTo);
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
    Navigator.of(context).pop(
      const _InvitationFilterResult(
        entity: null,
        site: null,
        department: null,
        visitorType: null,
        status: null,
        invitationId: '',
        dateFrom: '',
        dateTo: '',
        upcomingOnly: false,
        clearRequested: true,
      ),
    );
  }

  String _toDisplayError(Object error, {required String fallback}) {
    final text = error.toString().trim();
    if (text.startsWith('Exception:')) {
      return text.replaceFirst('Exception:', '').trim();
    }
    return text.isEmpty ? fallback : text;
  }

  String _entityOptionLabel(EntityOption option) {
    return option.label.trim().isEmpty ? '(Blank)' : option.label;
  }

  String _siteOptionLabel(SiteOption option) {
    final label = option.label.trim();
    if (label.isNotEmpty) {
      return label;
    }
    return option.value.trim().isEmpty ? '(Blank)' : option.value;
  }

  String _departmentOptionLabel(DepartmentOption option) {
    return option.label.trim().isEmpty ? '(Blank)' : option.label;
  }

  String _visitorTypeOptionLabel(VisitorTypeOption option) {
    final label = option.label.trim();
    if (label.isNotEmpty) {
      return label;
    }
    return option.value.trim().isEmpty ? '(Blank)' : option.value;
  }

  String? _selectedEntityLabel({
    required List<EntityOption> options,
    required String? selectedCode,
  }) {
    if (selectedCode == null) return null;
    for (final option in options) {
      if (option.value == selectedCode) {
        return _entityOptionLabel(option);
      }
    }
    return selectedCode;
  }

  String? _selectedSiteLabel({
    required List<SiteOption> options,
    required String? selectedCode,
  }) {
    if (selectedCode == null) return null;
    for (final option in options) {
      if (option.value == selectedCode) {
        return _siteOptionLabel(option);
      }
    }
    return selectedCode;
  }

  String? _selectedDepartmentLabel({
    required List<DepartmentOption> options,
    required String? selectedCode,
  }) {
    if (selectedCode == null) return null;
    for (final option in options) {
      if (option.value == selectedCode) {
        return _departmentOptionLabel(option);
      }
    }
    return selectedCode;
  }

  String? _selectedVisitorTypeLabel({
    required List<VisitorTypeOption> options,
    required String? selectedCode,
  }) {
    if (selectedCode == null) return null;
    for (final option in options) {
      if (option.value == selectedCode) {
        return _visitorTypeOptionLabel(option);
      }
    }
    return selectedCode;
  }

  void _syncSelectionWithOptions({
    required bool optionsReady,
    required bool enabled,
    required String? selectedValue,
    required bool Function(String value) containsValue,
    required VoidCallback clearSelection,
  }) {
    if (!mounted || !optionsReady || !enabled || selectedValue == null) {
      return;
    }
    if (containsValue(selectedValue)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(clearSelection);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entityOptionsAsync = ref.watch(entityOptionsProvider);
    final entityOptions = entityOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <EntityOption>[],
    );
    final entityDisplayValue = _selectedEntityLabel(
      options: entityOptions,
      selectedCode: _entity,
    );
    final entityLoadError = entityOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load entities. Tap to retry.',
      ),
    );

    final siteOptionsAsync = ref.watch(siteOptionsProvider(_entity));
    final siteOptions = siteOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <SiteOption>[],
    );
    final siteDisplayValue = _selectedSiteLabel(
      options: siteOptions,
      selectedCode: _site,
    );
    final siteLoadError = siteOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load sites. Tap to retry.',
      ),
    );
    final canRetrySite = _entity != null && siteOptionsAsync.hasError;
    final canPickSite =
        _entity != null &&
        !siteOptionsAsync.isLoading &&
        !siteOptionsAsync.hasError;
    final enableSiteField = _entity != null && !siteOptionsAsync.isLoading;

    final departmentOptionsAsync = ref.watch(
      departmentOptionsProvider(_entity),
    );
    final departmentOptions = departmentOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <DepartmentOption>[],
    );
    final departmentDisplayValue = _selectedDepartmentLabel(
      options: departmentOptions,
      selectedCode: _department,
    );
    final departmentLoadError = departmentOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load departments. Tap to retry.',
      ),
    );
    final canRetryDepartment =
        _entity != null && departmentOptionsAsync.hasError;
    final canPickDepartment =
        _entity != null &&
        !departmentOptionsAsync.isLoading &&
        !departmentOptionsAsync.hasError;
    final enableDepartmentField =
        _entity != null && !departmentOptionsAsync.isLoading;

    final visitorTypeOptionsAsync = ref.watch(visitorTypeOptionsProvider);
    final visitorTypeOptions = visitorTypeOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <VisitorTypeOption>[],
    );
    final visitorTypeDisplayValue = _selectedVisitorTypeLabel(
      options: visitorTypeOptions,
      selectedCode: _visitorType,
    );
    final visitorTypeLoadError = visitorTypeOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load visitor types. Tap to retry.',
      ),
    );
    final canPickVisitorType =
        !visitorTypeOptionsAsync.isLoading && !visitorTypeOptionsAsync.hasError;

    _syncSelectionWithOptions(
      optionsReady: siteOptionsAsync.hasValue,
      enabled: _entity != null,
      selectedValue: _site,
      containsValue: (value) =>
          siteOptions.any((option) => option.value == value),
      clearSelection: () => _site = null,
    );
    _syncSelectionWithOptions(
      optionsReady: departmentOptionsAsync.hasValue,
      enabled: _entity != null,
      selectedValue: _department,
      containsValue: (value) =>
          departmentOptions.any((option) => option.value == value),
      clearSelection: () => _department = null,
    );
    _syncSelectionWithOptions(
      optionsReady: visitorTypeOptionsAsync.hasValue,
      enabled: true,
      selectedValue: _visitorType,
      containsValue: (value) =>
          visitorTypeOptions.any((option) => option.value == value),
      clearSelection: () => _visitorType = null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [TextButton(onPressed: _clearAll, child: const Text('Clear'))],
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
                    onTap: () async {
                      if (entityOptionsAsync.hasError) {
                        ref.invalidate(entityOptionsProvider);
                        return;
                      }
                      if (entityOptions.isEmpty) return;
                      final selected = await _pickFilterOption(
                        title: 'Entity',
                        options: entityOptions
                            .map(_entityOptionLabel)
                            .toList(growable: false),
                        currentValue: entityDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = entityOptions.firstWhere(
                        (option) => _entityOptionLabel(option) == selected,
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
                            .map(_siteOptionLabel)
                            .toList(growable: false),
                        currentValue: siteDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = siteOptions.firstWhere(
                        (option) => _siteOptionLabel(option) == selected,
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
                            .map(_departmentOptionLabel)
                            .toList(growable: false),
                        currentValue: departmentDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = departmentOptions.firstWhere(
                        (option) => _departmentOptionLabel(option) == selected,
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
                            .map(_visitorTypeOptionLabel)
                            .toList(growable: false),
                        currentValue: visitorTypeDisplayValue,
                      );
                      if (!mounted || selected == null) return;

                      final pickedOption = visitorTypeOptions.firstWhere(
                        (option) => _visitorTypeOptionLabel(option) == selected,
                        orElse: () =>
                            const VisitorTypeOption(value: '', label: ''),
                      );
                      final selectedValue = pickedOption.value.trim().isEmpty
                          ? null
                          : pickedOption.value;

                      setState(() => _visitorType = selectedValue);
                    },
                  ),
                  LabeledTextInputRow(
                    label: 'Invitation ID',
                    controller: _invitationIdController,
                  ),
                  LabeledSelectRow(
                    label: 'Visit Date From',
                    value: _dateFromController.text.isEmpty
                        ? null
                        : _dateFromController.text,
                    placeholder: 'Please select',
                    onTap: () => _pickDate(controller: _dateFromController),
                  ),
                  LabeledSelectRow(
                    label: 'Visit Date To',
                    value: _dateToController.text.isEmpty
                        ? null
                        : _dateToController.text,
                    placeholder: 'Please select',
                    onTap: () => _pickDate(controller: _dateToController),
                  ),
                  LabeledSelectRow(
                    label: 'Status',
                    value: _status,
                    placeholder: 'Please select',
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
    required this.selected,
    required this.onSelected,
  });

  final _InvitationItem item;
  final bool selected;
  final ValueChanged<bool?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Checkbox(value: selected, onChanged: onSelected),
            Expanded(
              child: Text(
                item.invitationId,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            InfoRow(label: 'Status', value: item.status),
            InfoRow(label: 'Purpose', value: item.purpose),
            InfoRow(
              label: 'Visit',
              value:
                  '${item.visitDateFrom} ${item.visitTimeFrom} → ${item.visitDateTo} ${item.visitTimeTo}',
            ),
          ],
        ),
        children: [
          InfoRow(label: 'Entity', value: item.entity),
          InfoRow(label: 'Site', value: item.site),
          InfoRow(label: 'Department', value: item.department),
          InfoRow(label: 'Person to Visit', value: item.personToVisit),
          InfoRow(label: 'Visitor Type', value: item.visitorType),
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

class _InvitationItem {
  const _InvitationItem({
    required this.invitationId,
    required this.entity,
    required this.site,
    required this.department,
    required this.personToVisit,
    required this.createdBy,
    required this.visitorType,
    required this.company,
    required this.vehiclePlateNumber,
    required this.status,
    required this.purpose,
    required this.visitDateFrom,
    required this.visitTimeFrom,
    required this.visitDateTo,
    required this.visitTimeTo,
    required this.createDate,
    required this.updateDate,
    required this.updateBy,
  });

  final String invitationId;
  final String entity;
  final String site;
  final String department;
  final String personToVisit;
  final String createdBy;
  final String visitorType;
  final String company;
  final String vehiclePlateNumber;
  final String status;
  final String purpose;
  final String visitDateFrom;
  final String visitTimeFrom;
  final String visitDateTo;
  final String visitTimeTo;
  final String createDate;
  final String updateDate;
  final String updateBy;

  _InvitationItem copyWith({
    String? invitationId,
    String? entity,
    String? site,
    String? department,
    String? personToVisit,
    String? createdBy,
    String? visitorType,
    String? company,
    String? vehiclePlateNumber,
    String? status,
    String? purpose,
    String? visitDateFrom,
    String? visitTimeFrom,
    String? visitDateTo,
    String? visitTimeTo,
    String? createDate,
    String? updateDate,
    String? updateBy,
  }) {
    return _InvitationItem(
      invitationId: invitationId ?? this.invitationId,
      entity: entity ?? this.entity,
      site: site ?? this.site,
      department: department ?? this.department,
      personToVisit: personToVisit ?? this.personToVisit,
      createdBy: createdBy ?? this.createdBy,
      visitorType: visitorType ?? this.visitorType,
      company: company ?? this.company,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      visitDateFrom: visitDateFrom ?? this.visitDateFrom,
      visitTimeFrom: visitTimeFrom ?? this.visitTimeFrom,
      visitDateTo: visitDateTo ?? this.visitDateTo,
      visitTimeTo: visitTimeTo ?? this.visitTimeTo,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      updateBy: updateBy ?? this.updateBy,
    );
  }
}
