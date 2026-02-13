import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/app_filled_button.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/info_row.dart';
import '../widgets/searchable_option_sheet.dart';

const Map<String, List<String>> _mockEntitySites = {
  'AGYTEK - Agytek1231': ['FACTORY1 - FACTORY1 T', 'FACTORY2 - FACTORY2 A'],
  'BERNAS - BERNAS01': ['HQ - BERNAS HQ', 'WAREHOUSE - BERNAS W1'],
  'SCOPE - SCP100': ['PLANT - SCP P1'],
};

Future<List<String>> _fetchSitesForEntityMock(String entity) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  if (entity == 'SCOPE - SCP100') {
    throw Exception('Mock site API error');
  }
  return _mockEntitySites[entity] ?? const [];
}

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

class _InvitationFilterPage extends StatefulWidget {
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
  State<_InvitationFilterPage> createState() => _InvitationFilterPageState();
}

class _InvitationFilterPageState extends State<_InvitationFilterPage> {
  late final TextEditingController _invitationIdController;
  late final TextEditingController _dateFromController;
  late final TextEditingController _dateToController;

  String? _entity;
  String? _site;
  String? _department;
  String? _visitorType;
  String? _status;
  bool _upcomingOnly = false;
  List<String> _siteOptions = const [];
  bool _isSiteLoading = false;
  String? _siteLoadError;

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
    if (_entity != null) {
      _loadSitesForEntity(_entity!, keepCurrentSite: true);
    }
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

  Future<void> _loadSitesForEntity(
    String entity, {
    required bool keepCurrentSite,
  }) async {
    setState(() {
      if (!keepCurrentSite) {
        _site = null;
      }
      _siteOptions = const [];
      _isSiteLoading = true;
      _siteLoadError = null;
    });
    try {
      final sites = await _fetchSitesForEntityMock(entity);
      if (!mounted) return;
      setState(() {
        _siteOptions = sites;
        _isSiteLoading = false;
        if (_site != null && !_siteOptions.contains(_site)) {
          _site = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _siteOptions = const [];
        _isSiteLoading = false;
        _siteLoadError = 'Failed to load sites. Tap Site to retry.';
      });
    }
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

  @override
  Widget build(BuildContext context) {
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
                    value: _entity,
                    placeholder: 'Please select',
                    onTap: () async {
                      final selected = await _pickFilterOption(
                        title: 'Entity',
                        options: _mockEntitySites.keys.toList(growable: false),
                        currentValue: _entity,
                      );
                      if (!mounted || selected == null) return;
                      setState(() => _entity = selected);
                      await _loadSitesForEntity(
                        selected,
                        keepCurrentSite: false,
                      );
                    },
                  ),
                  LabeledSelectRow(
                    label: 'Site',
                    isRequired: true,
                    value: _site,
                    placeholder: _entity == null
                        ? 'Select entity first'
                        : _isSiteLoading
                        ? 'Loading...'
                        : _siteLoadError != null
                        ? _siteLoadError!
                        : 'Please select',
                    enabled: _entity != null && !_isSiteLoading,
                    onTap: () async {
                      if (_entity == null) return;
                      if (_siteLoadError != null) {
                        await _loadSitesForEntity(
                          _entity!,
                          keepCurrentSite: false,
                        );
                        return;
                      }
                      final selected = await _pickFilterOption(
                        title: 'Site',
                        options: _siteOptions,
                        currentValue: _site,
                      );
                      if (!mounted || selected == null) return;
                      setState(() => _site = selected);
                    },
                  ),
                  LabeledSelectRow(
                    label: 'Department',
                    isRequired: true,
                    value: _department,
                    placeholder: 'Please select',
                    onTap: () async {
                      final selected = await _pickFilterOption(
                        title: 'Department',
                        options: const ['ADMIN CENTER', 'OPERATIONS'],
                        currentValue: _department,
                      );
                      if (!mounted || selected == null) return;
                      setState(() => _department = selected);
                    },
                  ),
                  LabeledSelectRow(
                    label: 'Visitor Type',
                    value: _visitorType,
                    placeholder: 'Please select',
                    onTap: () async {
                      final selected = await _pickFilterOption(
                        title: 'Visitor Type',
                        options: const ['Visitor', 'Contractor'],
                        currentValue: _visitorType,
                      );
                      if (!mounted || selected == null) return;
                      setState(() => _visitorType = selected);
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
