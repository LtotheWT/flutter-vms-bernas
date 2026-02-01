import 'package:flutter/material.dart';

import '../widgets/app_dropdown_form_field.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/info_row.dart';

class PermanentContractorLogPage extends StatefulWidget {
  const PermanentContractorLogPage({super.key});

  @override
  State<PermanentContractorLogPage> createState() =>
      _PermanentContractorLogPageState();
}

class _PermanentContractorLogPageState
    extends State<PermanentContractorLogPage> {
  final _contractorIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _icController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();

  String? _entity;
  String? _site;
  String? _gate;
  String? _status;

  final List<_PermanentContractorLogItem> _items = [
    const _PermanentContractorLogItem(
      contractorId: 'PC-00078',
      site: 'FACTORY1 T',
      name: 'Ravi Kumar',
      icNumber: 'C1122334',
      vehicleNo: 'VBA 8821',
      date: '01/02/2026',
      checkIn: '01/02/2026 08:10 AM',
      checkOut: '01/02/2026 06:05 PM',
      gateIn: 'F1_A',
      gateOut: 'F1_B',
      checkInBy: 'admin',
      checkOutBy: 'admin',
      createDate: '31/01/2026 04:18 PM',
      createBy: 'ryan',
    ),
    const _PermanentContractorLogItem(
      contractorId: 'PC-00083',
      site: 'FACTORY1 T',
      name: 'Nur Farah',
      icNumber: 'D4455667',
      vehicleNo: '-',
      date: '01/02/2026',
      checkIn: '01/02/2026 07:55 AM',
      checkOut: '-',
      gateIn: 'F1_A',
      gateOut: '-',
      checkInBy: 'ryan',
      checkOutBy: '-',
      createDate: '31/01/2026 02:09 PM',
      createBy: 'admin',
    ),
  ];

  @override
  void dispose() {
    _contractorIdController.dispose();
    _nameController.dispose();
    _icController.dispose();
    _vehicleNoController.dispose();
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
                    AppTextFormField(
                      controller: _dateFromController,
                      label: 'Date From',
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () => _pickDate(controller: _dateFromController),
                    ),
                    AppTextFormField(
                      controller: _dateToController,
                      label: 'Date To',
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () => _pickDate(controller: _dateToController),
                    ),
                    AppTextFormField(
                      controller: _contractorIdController,
                      label: 'Contractor ID',
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
                      label: 'IC Number/Passport Number',
                    ),
                    AppTextFormField(
                      controller: _vehicleNoController,
                      label: 'Vehicle No',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FilterRow(
                  children: [
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
        title: const Text('Permanent Contractor Log'),
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
  final List<_PermanentContractorLogItem> items;

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
          _PermanentContractorLogCard(item: item, textTheme: textTheme),
      ],
    );
  }
}

class _PermanentContractorLogCard extends StatelessWidget {
  const _PermanentContractorLogCard({
    required this.item,
    required this.textTheme,
  });

  final _PermanentContractorLogItem item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          item.contractorId,
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
                InfoRow(label: 'Site', value: item.site),
                InfoRow(label: 'Vehicle No', value: item.vehicleNo),
                InfoRow(label: 'Date', value: item.date),
                InfoRow(label: 'Check-In', value: item.checkIn),
                InfoRow(label: 'Check-Out', value: item.checkOut),
                InfoRow(label: 'Gate In', value: item.gateIn),
                InfoRow(label: 'Gate Out', value: item.gateOut),
                InfoRow(label: 'Check-In By', value: item.checkInBy),
                InfoRow(label: 'Check-Out By', value: item.checkOutBy),
                InfoRow(label: 'Create Date', value: item.createDate),
                InfoRow(label: 'Create By', value: item.createBy),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermanentContractorLogItem {
  const _PermanentContractorLogItem({
    required this.contractorId,
    required this.site,
    required this.name,
    required this.icNumber,
    required this.vehicleNo,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.gateIn,
    required this.gateOut,
    required this.checkInBy,
    required this.checkOutBy,
    required this.createDate,
    required this.createBy,
  });

  final String contractorId;
  final String site;
  final String name;
  final String icNumber;
  final String vehicleNo;
  final String date;
  final String checkIn;
  final String checkOut;
  final String gateIn;
  final String gateOut;
  final String checkInBy;
  final String checkOutBy;
  final String createDate;
  final String createBy;
}
