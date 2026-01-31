import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

  Future<void> _pickDate({required TextEditingController controller}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${_two(picked.month)}-${_two(picked.day)}';
    }
  }

  String _two(int value) => value.toString().padLeft(2, '0');

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
          FilledButton(
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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _entity,
                  decoration: const InputDecoration(labelText: 'Entity *'),
                  items: const [
                    DropdownMenuItem(
                      value: 'AGYTEK - Agytek1231',
                      child: Text('AGYTEK - Agytek1231'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _entity = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _site,
                  decoration: const InputDecoration(labelText: 'Site *'),
                  items: const [
                    DropdownMenuItem(
                      value: 'FACTORY1 - FACTORY1 T',
                      child: Text('FACTORY1 - FACTORY1 T'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _site = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _department,
                  decoration: const InputDecoration(labelText: 'Department *'),
                  items: const [
                    DropdownMenuItem(
                      value: 'ADMIN CENTER',
                      child: Text('ADMIN CENTER'),
                    ),
                    DropdownMenuItem(
                      value: 'OPERATIONS',
                      child: Text('OPERATIONS'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _department = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _visitorType,
                  decoration: const InputDecoration(labelText: 'Visitor Type'),
                  items: const [
                    DropdownMenuItem(value: 'Visitor', child: Text('Visitor')),
                    DropdownMenuItem(
                      value: 'Contractor',
                      child: Text('Contractor'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _visitorType = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _invitationIdController,
                  decoration: const InputDecoration(labelText: 'Invitation ID'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateFromController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Visit Date From',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(controller: _dateFromController),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateToController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Visit Date To',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(controller: _dateToController),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'New', child: Text('New')),
                    DropdownMenuItem(
                      value: 'Approved',
                      child: Text('Approved'),
                    ),
                    DropdownMenuItem(
                      value: 'Rejected',
                      child: Text('Rejected'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _status = value),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _upcomingOnly,
                  title: const Text('Upcoming Visitor'),
                  onChanged: (value) => setState(() => _upcomingOnly = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Search'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _clearFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
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
                        OutlinedButton.icon(
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
            _InfoRow(label: 'Status', value: item.status),
            _InfoRow(label: 'Purpose', value: item.purpose),
            _InfoRow(
              label: 'Visit',
              value:
                  '${item.visitDateFrom} ${item.visitTimeFrom} → ${item.visitDateTo} ${item.visitTimeTo}',
            ),
          ],
        ),
        children: [
          _InfoRow(label: 'Entity', value: item.entity),
          _InfoRow(label: 'Site', value: item.site),
          _InfoRow(label: 'Department', value: item.department),
          _InfoRow(label: 'Person to Visit', value: item.personToVisit),
          _InfoRow(label: 'Visitor Type', value: item.visitorType),
          _InfoRow(label: 'Company', value: item.company),
          _InfoRow(label: 'Vehicle Plate', value: item.vehiclePlateNumber),
          _InfoRow(label: 'Created By', value: item.createdBy),
          _InfoRow(label: 'Create Date', value: item.createDate),
          _InfoRow(label: 'Update Date', value: item.updateDate),
          _InfoRow(label: 'Update By', value: item.updateBy),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodySmall)),
        ],
      ),
    );
  }
}
