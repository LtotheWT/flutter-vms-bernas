import 'package:flutter/material.dart';

class VisitorCheckInPage extends StatefulWidget {
  const VisitorCheckInPage({super.key, required this.isCheckIn});

  final bool isCheckIn;

  @override
  State<VisitorCheckInPage> createState() => _VisitorCheckInPageState();
}

class _VisitorCheckInPageState extends State<VisitorCheckInPage> {
  final _scanController = TextEditingController();
  final Set<int> _selectedIndexes = <int>{};
  final List<_VisitorRow> _visitors = [
    const _VisitorRow(
      name: 'AAAA',
      idNumber: 'AAAA',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:00 AM',
      checkOutDate: '-',
      hasPhoto: true,
    ),
    const _VisitorRow(
      name: 'BBBB',
      idNumber: 'BBB',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:05 AM',
      checkOutDate: '-',
      hasPhoto: false,
    ),
    const _VisitorRow(
      name: 'CCCC',
      idNumber: 'CCCC',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:10 AM',
      checkOutDate: '-',
      hasPhoto: true,
    ),
    const _VisitorRow(
      name: 'DDDD',
      idNumber: 'DDD',
      checkStatus: 'IN',
      checkInDate: '31/01/2026 09:15 AM',
      checkOutDate: '-',
      hasPhoto: false,
    ),
  ];

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCheckIn ? 'Visitor Check-In' : 'Visitor Check-Out',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Scan',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _scanController,
                    decoration: const InputDecoration(
                      labelText: 'Scan QR Code',
                      suffixIcon: Icon(Icons.qr_code_scanner),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Scan Physical Tag',
                      suffixIcon: Icon(Icons.nfc),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Buttons removed; scan actions are via field suffix icons.
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Visitor Summary',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Invitation ID', value: 'IV20251200074'),
                  _InfoRow(label: 'Department', value: 'Admin Center'),
                  _InfoRow(label: 'Purpose', value: 'Meeting'),
                  _InfoRow(label: 'Site', value: 'FACTORY1 T'),
                  _InfoRow(label: 'Company', value: 'JOHNHANSON LIMITED'),
                  _InfoRow(label: 'Contact', value: '012-3456789'),
                  const Divider(height: 24),
                  _InfoRow(label: 'Visitor Type', value: 'Visitor'),
                  _InfoRow(label: 'Invite By', value: 'Suraya'),
                  _InfoRow(label: 'Work Level', value: 'Low'),
                  _InfoRow(label: 'Vehicle Plate', value: 'WSD 011234'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Visitor List',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value:
                      _selectedIndexes.length == _visitors.length &&
                      _visitors.isNotEmpty,
                  onChanged: _visitors.isEmpty
                      ? null
                      : (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedIndexes
                                ..clear()
                                ..addAll(
                                  List<int>.generate(
                                    _visitors.length,
                                    (index) => index,
                                  ),
                                );
                            } else {
                              _selectedIndexes.clear();
                            }
                          });
                        },
                  title: Text(
                    'Select all (${_selectedIndexes.length}/${_visitors.length})',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _visitors.length; i++)
            _VisitorCard(
              visitor: _visitors[i],
              selected: _selectedIndexes.contains(i),
              onSelected: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedIndexes.add(i);
                  } else {
                    _selectedIndexes.remove(i);
                  }
                });
              },
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Take Photo',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _PhotoThumb(hasPhoto: true),
                      _PhotoThumb(hasPhoto: false),
                      _PhotoThumb(hasPhoto: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _selectedIndexes.isEmpty ? null : () {},
          child: Text(
            widget.isCheckIn ? 'Confirm Check-In' : 'Confirm Check-Out',
          ),
        ),
      ),
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

class _VisitorCard extends StatelessWidget {
  const _VisitorCard({
    required this.visitor,
    required this.selected,
    required this.onSelected,
  });

  final _VisitorRow visitor;
  final bool selected;
  final ValueChanged<bool?> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(value: selected, onChanged: onSelected),
                Expanded(
                  child: Text(
                    visitor.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _InfoRow(label: 'Name', value: visitor.name),
            _InfoRow(label: 'IC/Passport', value: visitor.idNumber),
            _InfoRow(label: 'Check In/Out', value: visitor.checkStatus),
            _InfoRow(label: 'Check In Date', value: visitor.checkInDate),
            _InfoRow(label: 'Check Out Date', value: visitor.checkOutDate),
            _InfoRow(label: 'Gate In', value: 'F1_A'),
            _InfoRow(label: 'Gate Out', value: '-'),
            _InfoRow(label: 'Check In By', value: 'ryan'),
            _InfoRow(label: 'Check Out By', value: '-'),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    'Physical Tag',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixIcon: Icon(Icons.qr_code_scanner),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    'Visitor Photo',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                _PhotoMock(hasPhoto: visitor.hasPhoto),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitorRow {
  const _VisitorRow({
    required this.name,
    required this.idNumber,
    required this.checkStatus,
    required this.checkInDate,
    required this.checkOutDate,
    required this.hasPhoto,
  });

  final String name;
  final String idNumber;
  final String checkStatus;
  final String checkInDate;
  final String checkOutDate;
  final bool hasPhoto;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _PhotoMock extends StatelessWidget {
  const _PhotoMock({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 72,
        width: 72,
        color: hasPhoto ? colorScheme.primaryContainer : Colors.grey.shade300,
        child: Icon(
          hasPhoto ? Icons.check_circle : Icons.person,
          size: 30,
          color: hasPhoto ? colorScheme.onPrimaryContainer : Colors.black54,
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _PhotoMock(hasPhoto: hasPhoto),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, size: 12),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minHeight: 20, minWidth: 20),
            ),
          ),
        ),
      ],
    );
  }
}
