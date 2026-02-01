import 'package:flutter/material.dart';

import '../widgets/app_dropdown_form_field.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/info_row.dart';

class VisitorLogPage extends StatefulWidget {
  const VisitorLogPage({super.key});

  @override
  State<VisitorLogPage> createState() => _VisitorLogPageState();
}

class _VisitorLogPageState extends State<VisitorLogPage> {
  final _invitationIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _icController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();

  String? _entity;
  String? _site;
  String? _gate;
  String? _department;
  String? _unit;
  String? _visitorType;
  String? _status;

  final List<_VisitorLogItem> _items = [
    const _VisitorLogItem(
      invitationId: 'IV20260201001',
      department: 'Admin Center',
      personToVisit: 'Suraya',
      name: 'John Tan',
      icNumber: 'A1234567',
      physicalTag: 'TAG-001',
      vehiclePlateNumber: 'WSD 011234',
      visitDateFrom: '01/02/2026',
      visitTimeFrom: '09:00 AM',
      visitDateTo: '01/02/2026',
      visitTimeTo: '12:00 PM',
      checkIn: '01/02/2026 09:05 AM',
      checkOut: '01/02/2026 11:45 AM',
      gateIn: 'F1_A',
      gateOut: 'F1_B',
      checkInBy: 'ryan',
      checkOutBy: 'ryan',
    ),
    const _VisitorLogItem(
      invitationId: 'IV20260201002',
      department: 'Operations',
      personToVisit: 'Aisha',
      name: 'Nur Alia',
      icNumber: 'B9988776',
      physicalTag: 'TAG-014',
      vehiclePlateNumber: 'VBA 8821',
      visitDateFrom: '01/02/2026',
      visitTimeFrom: '02:30 PM',
      visitDateTo: '01/02/2026',
      visitTimeTo: '05:00 PM',
      checkIn: '01/02/2026 02:33 PM',
      checkOut: '-',
      gateIn: 'F1_A',
      gateOut: '-',
      checkInBy: 'admin',
      checkOutBy: '-',
    ),
  ];

  @override
  void dispose() {
    _invitationIdController.dispose();
    _nameController.dispose();
    _icController.dispose();
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
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
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
                _FilterRow(
                  children: [
                    AppDropdownFormField<String>(
                      value: _entity,
                      label: 'Entity *',
                      items: [
                        AppDropdownMenuItem(
                          value: 'AGYTEK - Agytek1231',
                          label: 'AGYTEK - Agytek1231',
                        ),
                      ],
                      onChanged: (value) => setState(() => _entity = value),
                    ),
                    AppDropdownFormField<String>(
                      value: _site,
                      label: 'Site *',
                      items: [
                        AppDropdownMenuItem(
                          value: 'FACTORY1 - FACTORY1 T',
                          label: 'FACTORY1 - FACTORY1 T',
                        ),
                      ],
                      onChanged: (value) => setState(() => _site = value),
                    ),
                    AppDropdownFormField<String>(
                      value: _gate,
                      label: 'Gate',
                      items: [
                        AppDropdownMenuItem(value: 'Gate A', label: 'Gate A'),
                        AppDropdownMenuItem(value: 'Gate B', label: 'Gate B'),
                      ],
                      onChanged: (value) => setState(() => _gate = value),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FilterRow(
                  children: [
                    AppDropdownFormField<String>(
                      value: _department,
                      label: 'Department',
                      items: [
                        AppDropdownMenuItem(
                          value: 'ADMIN CENTER',
                          label: 'ADMIN CENTER',
                        ),
                        AppDropdownMenuItem(
                          value: 'OPERATIONS',
                          label: 'OPERATIONS',
                        ),
                      ],
                      onChanged: (value) => setState(() => _department = value),
                    ),
                    AppDropdownFormField<String>(
                      value: _unit,
                      label: 'Unit',
                      items: [
                        AppDropdownMenuItem(value: 'Unit 1', label: 'Unit 1'),
                        AppDropdownMenuItem(value: 'Unit 2', label: 'Unit 2'),
                      ],
                      onChanged: (value) => setState(() => _unit = value),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FilterRow(
                  children: [
                    AppTextFormField(
                      controller: _dateFromController,
                      label: 'Visit Date From',
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () => _pickDate(controller: _dateFromController),
                    ),
                    AppTextFormField(
                      controller: _dateToController,
                      label: 'Visit Date To',
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () => _pickDate(controller: _dateToController),
                    ),
                    AppTextFormField(
                      controller: _invitationIdController,
                      label: 'Invitation ID',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FilterRow(
                  children: [
                    AppTextFormField(
                      controller: _nameController,
                      label: 'Name',
                    ),
                    AppTextFormField(
                      controller: _icController,
                      label: 'IC/Passport Number',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FilterRow(
                  children: [
                    AppDropdownFormField<String>(
                      value: _visitorType,
                      label: 'Visitor Type',
                      items: [
                        AppDropdownMenuItem(value: 'Visitor', label: 'Visitor'),
                        AppDropdownMenuItem(
                          value: 'Contractor',
                          label: 'Contractor',
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _visitorType = value),
                    ),
                    AppDropdownFormField<String>(
                      value: _status,
                      label: 'Status',
                      items: [
                        AppDropdownMenuItem(value: 'All', label: 'All'),
                        AppDropdownMenuItem(value: 'In', label: 'In'),
                        AppDropdownMenuItem(value: 'Out', label: 'Out'),
                      ],
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppFilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Search'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppOutlinedButton(
                        onPressed: () {},
                        child: const Text('Export'),
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
        title: const Text('Visitor Pass Log'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const SizedBox(height: 4),
          Text(
            'Results',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _ResultsList(textTheme: textTheme, items: _items),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        if (constraints.maxWidth < 640) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                children[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.textTheme, required this.items});

  final TextTheme textTheme;
  final List<_VisitorLogItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No records to display.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          _VisitorLogCard(item: item, textTheme: textTheme),
      ],
    );
  }
}

class _VisitorLogCard extends StatelessWidget {
  const _VisitorLogCard({required this.item, required this.textTheme});

  final _VisitorLogItem item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
            InfoRow(label: 'Name', value: item.name),
            InfoRow(label: 'IC/Passport', value: item.icNumber),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                InfoRow(label: 'Department', value: item.department),
                InfoRow(label: 'Person To Visit', value: item.personToVisit),
                InfoRow(label: 'Physical Tag', value: item.physicalTag),
                InfoRow(label: 'Vehicle Plate', value: item.vehiclePlateNumber),
                InfoRow(label: 'Visit Date From', value: item.visitDateFrom),
                InfoRow(label: 'Visit Time From', value: item.visitTimeFrom),
                InfoRow(label: 'Visit Date To', value: item.visitDateTo),
                InfoRow(label: 'Visit Time To', value: item.visitTimeTo),
                InfoRow(label: 'Check-In', value: item.checkIn),
                InfoRow(label: 'Check-Out', value: item.checkOut),
                InfoRow(label: 'Gate In', value: item.gateIn),
                InfoRow(label: 'Gate Out', value: item.gateOut),
                InfoRow(label: 'Check-In By', value: item.checkInBy),
                InfoRow(label: 'Check-Out By', value: item.checkOutBy),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorLogItem {
  const _VisitorLogItem({
    required this.invitationId,
    required this.department,
    required this.personToVisit,
    required this.name,
    required this.icNumber,
    required this.physicalTag,
    required this.vehiclePlateNumber,
    required this.visitDateFrom,
    required this.visitTimeFrom,
    required this.visitDateTo,
    required this.visitTimeTo,
    required this.checkIn,
    required this.checkOut,
    required this.gateIn,
    required this.gateOut,
    required this.checkInBy,
    required this.checkOutBy,
  });

  final String invitationId;
  final String department;
  final String personToVisit;
  final String name;
  final String icNumber;
  final String physicalTag;
  final String vehiclePlateNumber;
  final String visitDateFrom;
  final String visitTimeFrom;
  final String visitDateTo;
  final String visitTimeTo;
  final String checkIn;
  final String checkOut;
  final String gateIn;
  final String gateOut;
  final String checkInBy;
  final String checkOutBy;
}
