import 'package:flutter/material.dart';

class VisitorWalkInPage extends StatefulWidget {
  const VisitorWalkInPage({super.key});

  @override
  State<VisitorWalkInPage> createState() => _VisitorWalkInPageState();
}

class _VisitorWalkInPageState extends State<VisitorWalkInPage> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _companyController = TextEditingController();
  final _contactController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _projectController = TextEditingController();
  final _workDescriptionController = TextEditingController();
  final _remarkController = TextEditingController();
  final _visitorNameController = TextEditingController();
  final _visitorIdController = TextEditingController();
  final FocusNode _visitorNameFocus = FocusNode();

  String? _entity;
  String? _site;
  String? _department;
  String? _personToVisit;
  String? _visitorType;
  String? _workLevel;
  int _currentStep = 0;
  final List<_VisitorEntry> _visitors = [];
  final Set<int> _selectedVisitorIndexes = <int>{};
  bool _policyOneOpened = false;
  bool _policyTwoOpened = false;

  @override
  void dispose() {
    _purposeController.dispose();
    _companyController.dispose();
    _contactController.dispose();
    _vehiclePlateController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _projectController.dispose();
    _workDescriptionController.dispose();
    _remarkController.dispose();
    _visitorNameController.dispose();
    _visitorIdController.dispose();
    _visitorNameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required TextEditingController controller,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) {
      return;
    }
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    controller.text = _formatDateTime(dateTime);
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$day/$month/$year $hour12:$minute $suffix';
  }

  Future<void> _openPolicy({required String title, required int index}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Policy content preview (mock).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    setState(() {
      if (index == 1) {
        _policyOneOpened = true;
      } else {
        _policyTwoOpened = true;
      }
    });
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  bool _validateStep(int step) {
    String? error;
    if (step == 0) {
      if (_entity == null) {
        error = 'Entity is required.';
      } else if (_site == null) {
        error = 'Site is required.';
      } else if (_department == null) {
        error = 'Department is required.';
      } else if (_personToVisit == null) {
        error = 'Person to visit is required.';
      } else if (_visitorType == null) {
        error = 'Visitor type is required.';
      } else if (_isBlank(_purposeController.text)) {
        error = 'Purpose is required.';
      }
    } else if (step == 1) {
      if (_isBlank(_companyController.text)) {
        error = 'Company is required.';
      } else if (_isBlank(_contactController.text)) {
        error = 'Contact number is required.';
      } else if (_isBlank(_vehiclePlateController.text)) {
        error = 'Vehicle plate number is required.';
      } else if (_isBlank(_dateFromController.text)) {
        error = 'Visit date from is required.';
      } else if (_isBlank(_dateToController.text)) {
        error = 'Visit date to is required.';
      }
    }

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return false;
    }
    return true;
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _purposeController.clear();
    _companyController.clear();
    _contactController.clear();
    _vehiclePlateController.clear();
    _dateFromController.clear();
    _dateToController.clear();
    _projectController.clear();
    _workDescriptionController.clear();
    _remarkController.clear();
    _visitorNameController.clear();
    _visitorIdController.clear();
    setState(() {
      _entity = null;
      _site = null;
      _department = null;
      _personToVisit = null;
      _visitorType = null;
      _workLevel = null;
      _visitors.clear();
      _selectedVisitorIndexes.clear();
      _policyOneOpened = false;
      _policyTwoOpened = false;
    });
  }

  Future<void> _confirmClear() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear form?'),
        content: const Text('This will clear all fields.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (shouldClear ?? false) {
      _clearForm();
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      if (_visitors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one visitor.')),
        );
        return;
      }
      if (_visitors.any((visitor) => !visitor.policyRead)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All visitors must mark Policy/Rules as read.'),
          ),
        );
        return;
      }
      _showReviewSheet();
    }
  }

  Future<void> _showReviewSheet() async {
    final shouldSubmit = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 16 + bottomInset),
                    children: [
                      Text(
                        'Review & Confirm',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      _ReviewRow(label: 'Entity', value: _entity ?? '-'),
                      _ReviewRow(label: 'Site', value: _site ?? '-'),
                      _ReviewRow(
                        label: 'Department',
                        value: _department ?? '-',
                      ),
                      _ReviewRow(
                        label: 'Person to Visit',
                        value: _personToVisit ?? '-',
                      ),
                      _ReviewRow(
                        label: 'Visitor Type',
                        value: _visitorType ?? '-',
                      ),
                      _ReviewRow(
                        label: 'Purpose',
                        value: _purposeController.text,
                      ),
                      const SizedBox(height: 8),
                      _ReviewRow(
                        label: 'Company',
                        value: _companyController.text,
                      ),
                      _ReviewRow(
                        label: 'Contact',
                        value: _contactController.text,
                      ),
                      _ReviewRow(
                        label: 'Vehicle Plate',
                        value: _vehiclePlateController.text,
                      ),
                      _ReviewRow(
                        label: 'Visit From',
                        value: _dateFromController.text,
                      ),
                      _ReviewRow(
                        label: 'Visit To',
                        value: _dateToController.text,
                      ),
                      const SizedBox(height: 8),
                      _ReviewRow(
                        label: 'Visitors Added',
                        value: _visitors.length.toString(),
                      ),
                      _ReviewRow(
                        label: 'Policies Read',
                        value: _visitors.every((visitor) => visitor.policyRead)
                            ? 'Yes'
                            : 'No',
                      ),
                      if (_visitors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Visitors',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 6),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _visitors.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final visitor = _visitors[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${index + 1}.'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(visitor.name),
                                      Text(
                                        visitor.idNumber,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Back to Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Confirm'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldSubmit ?? false) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Walk-in registered.')));
    }
  }

  void _addVisitor() {
    final name = _visitorNameController.text.trim();
    final id = _visitorIdController.text.trim();
    if (name.isEmpty || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and IC/Passport are required.')),
      );
      return;
    }
    setState(() {
      _visitors.insert(
        0,
        _VisitorEntry(
          name: name,
          idNumber: id,
          photoLabel: 'No photo',
          policyRead: false,
        ),
      );
      _visitorNameController.clear();
      _visitorIdController.clear();
      _visitorNameFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Walk-In'),
        actions: [
          TextButton(onPressed: _confirmClear, child: const Text('Clear')),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 3) {
                if (_validateStep(_currentStep)) {
                  setState(() => _currentStep = _currentStep + 1);
                }
                return;
              }
              _submit();
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep = _currentStep - 1);
              }
            },
            controlsBuilder: (context, details) {
              final isLast = _currentStep == 3;
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: details.onStepContinue,
                        child: Text(isLast ? 'Register Walk-In' : 'Next'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ),
                  ],
                ),
              );
            },
            onStepTapped: (index) {
              if (index <= _currentStep) {
                setState(() => _currentStep = index);
                return;
              }
              if (_validateStep(_currentStep)) {
                setState(() => _currentStep = index);
              }
            },
            steps: [
              Step(
                title: const Text('Invitation Details'),
                isActive: _currentStep == 0,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'All fields with an asterisk (*) are mandatory.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    const _ReadOnlyField(
                      label: 'Invitation ID',
                      value: 'Auto-generated',
                    ),
                    const SizedBox(height: 12),
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
                      validator: (value) =>
                          value == null ? 'Entity is required.' : null,
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
                      validator: (value) =>
                          value == null ? 'Site is required.' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _department,
                      decoration: const InputDecoration(
                        labelText: 'Department *',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'BOD1 - BOARD OF DIRECTOR',
                          child: Text('BOD1 - BOARD OF DIRECTOR'),
                        ),
                        DropdownMenuItem(
                          value: 'OPERATIONS',
                          child: Text('OPERATIONS'),
                        ),
                      ],
                      onChanged: (value) => setState(() => _department = value),
                      validator: (value) =>
                          value == null ? 'Department is required.' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _personToVisit,
                      decoration: const InputDecoration(
                        labelText: 'Person to Visit *',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Ryan', child: Text('Ryan')),
                        DropdownMenuItem(value: 'Aisha', child: Text('Aisha')),
                      ],
                      onChanged: (value) =>
                          setState(() => _personToVisit = value),
                      validator: (value) =>
                          value == null ? 'Person to visit is required.' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _visitorType,
                      decoration: const InputDecoration(
                        labelText: 'Visitor Type *',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Visitor',
                          child: Text('Visitor'),
                        ),
                        DropdownMenuItem(
                          value: 'Contractor',
                          child: Text('Contractor'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _visitorType = value),
                      validator: (value) =>
                          value == null ? 'Visitor type is required.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(labelText: 'Purpose *'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Purpose is required.'
                          : null,
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Visitor Information'),
                isActive: _currentStep == 1,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(labelText: 'Company *'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Company is required.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number *',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Contact number is required.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vehiclePlateController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Plate Number *',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vehicle plate number is required.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateFromController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Visit Date From *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () =>
                          _pickDateTime(controller: _dateFromController),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Visit date from is required.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateToController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Visit Date To *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _pickDateTime(controller: _dateToController),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Visit date to is required.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _projectController,
                      decoration: const InputDecoration(labelText: 'Project'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _workDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Work Description',
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _workLevel,
                      decoration: const InputDecoration(
                        labelText: 'Work Level',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (value) => setState(() => _workLevel = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _remarkController,
                      decoration: const InputDecoration(labelText: 'Remark'),
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Visitor List'),
                isActive: _currentStep == 2,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter Name and IC/Passport Number to enable photo capture.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Policy, Rules & Regulations',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _PolicyLink(
                              title: 'Environmental Policy',
                              opened: _policyOneOpened,
                              onTap: () => _openPolicy(
                                title: 'Environmental Policy',
                                index: 1,
                              ),
                            ),
                            _PolicyLink(
                              title: 'Safety Health Management Policy',
                              opened: _policyTwoOpened,
                              onTap: () => _openPolicy(
                                title: 'Safety Health Management Policy',
                                index: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Open both policies before marking "Read".',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _visitorNameController,
                      focusNode: _visitorNameFocus,
                      decoration: const InputDecoration(
                        labelText: 'Name (as per IC/Passport) *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _visitorIdController,
                      decoration: const InputDecoration(
                        labelText: 'IC/Passport Number *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo capture mock.')),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Visitor Photo'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _addVisitor,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add Visitor'),
                    ),
                    const SizedBox(height: 12),
                    if (_visitors.isEmpty)
                      const Text('No visitors added yet.')
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              value:
                                  _selectedVisitorIndexes.length ==
                                      _visitors.length &&
                                  _visitors.isNotEmpty,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedVisitorIndexes
                                      ..clear()
                                      ..addAll(
                                        List<int>.generate(
                                          _visitors.length,
                                          (index) => index,
                                        ),
                                      );
                                  } else {
                                    _selectedVisitorIndexes.clear();
                                  }
                                });
                              },
                              title: Text(
                                'Select all (${_selectedVisitorIndexes.length}/${_visitors.length})',
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _selectedVisitorIndexes.isEmpty
                                ? null
                                : () {
                                    setState(() {
                                      final toRemove =
                                          _selectedVisitorIndexes.toList()
                                            ..sort((a, b) => b.compareTo(a));
                                      for (final index in toRemove) {
                                        _visitors.removeAt(index);
                                      }
                                      _selectedVisitorIndexes.clear();
                                    });
                                  },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _visitors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final visitor = _visitors[index];
                          final selected = _selectedVisitorIndexes.contains(
                            index,
                          );
                          return Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: selected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedVisitorIndexes.add(index);
                                    } else {
                                      _selectedVisitorIndexes.remove(index);
                                    }
                                  });
                                },
                              ),
                              title: Text(visitor.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(visitor.idNumber),
                                  const SizedBox(height: 6),
                                  CheckboxListTile(
                                    value: visitor.policyRead,
                                    onChanged: (checked) {
                                      if (!(_policyOneOpened &&
                                          _policyTwoOpened)) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Open both policy links before marking as read.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() {
                                        _visitors[index] = visitor.copyWith(
                                          policyRead: checked ?? false,
                                        );
                                      });
                                    },
                                    title: const Text('Read'),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.photo_outlined, size: 28),
                                  Text(
                                    visitor.photoLabel,
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              Step(
                title: const Text('Others (Optional)'),
                isActive: _currentStep == 3,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload supporting documents if needed.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Document: Test Checklist (pdf)',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '1) Download template',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download_outlined),
                              label: const Text('Download Test Checklist'),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '2) Upload modified file',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Choose file'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No file chosen',
                                    style: textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Upload'),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '3) Uploaded file actions',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Download uploaded'),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Delete uploaded'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value),
    );
  }
}

class _VisitorEntry {
  const _VisitorEntry({
    required this.name,
    required this.idNumber,
    required this.photoLabel,
    required this.policyRead,
  });

  final String name;
  final String idNumber;
  final String photoLabel;
  final bool policyRead;

  _VisitorEntry copyWith({
    String? name,
    String? idNumber,
    String? photoLabel,
    bool? policyRead,
  }) {
    return _VisitorEntry(
      name: name ?? this.name,
      idNumber: idNumber ?? this.idNumber,
      photoLabel: photoLabel ?? this.photoLabel,
      policyRead: policyRead ?? this.policyRead,
    );
  }
}

class _PolicyLink extends StatelessWidget {
  const _PolicyLink({
    required this.title,
    required this.opened,
    required this.onTap,
  });

  final String title;
  final bool opened;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onTap,
            child: Align(alignment: Alignment.centerLeft, child: Text(title)),
          ),
        ),
        if (opened) const Icon(Icons.check_circle, size: 18),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
