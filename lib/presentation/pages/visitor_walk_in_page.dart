import 'package:flutter/material.dart';

import '../widgets/app_dropdown_form_field.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/double_back_exit_scope.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/read_only_field.dart';

class VisitorWalkInPage extends StatefulWidget {
  const VisitorWalkInPage({super.key});

  @override
  State<VisitorWalkInPage> createState() => _VisitorWalkInPageState();
}

class _VisitorWalkInPageState extends State<VisitorWalkInPage> {
  final _stepOneFormKey = GlobalKey<FormState>();
  final _stepTwoFormKey = GlobalKey<FormState>();
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
  bool _isSubmitting = false;

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

  bool _hasUnsavedChanges() {
    return !_isBlank(_purposeController.text) ||
        !_isBlank(_companyController.text) ||
        !_isBlank(_contactController.text) ||
        !_isBlank(_vehiclePlateController.text) ||
        !_isBlank(_dateFromController.text) ||
        !_isBlank(_dateToController.text) ||
        !_isBlank(_projectController.text) ||
        !_isBlank(_workDescriptionController.text) ||
        !_isBlank(_remarkController.text) ||
        !_isBlank(_visitorNameController.text) ||
        !_isBlank(_visitorIdController.text) ||
        _entity != null ||
        _site != null ||
        _department != null ||
        _personToVisit != null ||
        _visitorType != null ||
        _workLevel != null ||
        _visitors.isNotEmpty ||
        _selectedVisitorIndexes.isNotEmpty ||
        _policyOneOpened ||
        _policyTwoOpened;
  }

  bool _validateStepForm(int step) {
    if (step == 0) {
      return _stepOneFormKey.currentState?.validate() ?? false;
    }
    if (step == 1) {
      return _stepTwoFormKey.currentState?.validate() ?? false;
    }
    return true;
  }

  void _clearForm() {
    _stepOneFormKey.currentState?.reset();
    _stepTwoFormKey.currentState?.reset();
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
      _isSubmitting = false;
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
          AppFilledButton(
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

  Future<void> _submit() async {
    if (!_validateStepForm(0)) {
      setState(() => _currentStep = 0);
      return;
    }
    if (!_validateStepForm(1)) {
      setState(() => _currentStep = 1);
      return;
    }
    FocusScope.of(context).unfocus();
    if (_isSubmitting) {
      return;
    }
    if (_visitors.isEmpty) {
      showAppSnackBar(context, 'Add at least one visitor.');
      return;
    }
    if (_visitors.any((visitor) => !visitor.policyRead)) {
      showAppSnackBar(context, 'All visitors must mark Policy/Rules as read.');
      return;
    }
    await _showReviewSheet();
  }

  Future<void> _showReviewSheet() async {
    final shouldSubmit = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: scrollController,
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
                          value:
                              _visitors.every((visitor) => visitor.policyRead)
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
                            child: AppOutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Back to Edit'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppFilledButton(
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
            );
          },
        );
      },
    );

    if (shouldSubmit ?? false) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = true);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      showAppSnackBar(context, 'Walk-in registered.');
    }
  }

  void _addVisitor() {
    final name = _visitorNameController.text.trim();
    final id = _visitorIdController.text.trim();
    if (name.isEmpty || id.isEmpty) {
      showAppSnackBar(context, 'Name and IC/Passport are required.');
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

    return DoubleBackExitScope(
      hasUnsavedChanges: _hasUnsavedChanges(),
      isBlocked: _isSubmitting,
      child: LoadingOverlay(
        isLoading: _isSubmitting,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Visitor Walk-In'),
            actions: [
              TextButton(onPressed: _confirmClear, child: const Text('Clear')),
            ],
          ),
          body: SafeArea(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  if (_validateStepForm(_currentStep)) {
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
                        child: AppFilledButton(
                          onPressed: details.onStepContinue,
                          child: Text(isLast ? 'Register Walk-In' : 'Next'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStep > 0)
                        Expanded(
                          child: AppOutlinedButton(
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
                if (_validateStepForm(_currentStep)) {
                  setState(() => _currentStep = index);
                }
              },
              steps: [
                Step(
                  title: const Text('Invitation Details'),
                  isActive: _currentStep == 0,
                  content: Form(
                    key: _stepOneFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'All fields with an asterisk (*) are mandatory.',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        const ReadOnlyField(
                          label: 'Invitation ID',
                          value: 'Auto-generated',
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: _entity,
                          label: 'Entity *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: [
                            AppDropdownMenuItem(
                              value: 'AGYTEK - Agytek1231',
                              label: 'AGYTEK - Agytek1231',
                            ),
                          ],
                          onChanged: (value) => setState(() => _entity = value),
                          validator: (value) =>
                              value == null ? 'Entity is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: _site,
                          label: 'Site *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: [
                            AppDropdownMenuItem(
                              value: 'FACTORY1 - FACTORY1 T',
                              label: 'FACTORY1 - FACTORY1 T',
                            ),
                          ],
                          onChanged: (value) => setState(() => _site = value),
                          validator: (value) =>
                              value == null ? 'Site is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: _department,
                          label: 'Department *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: [
                            AppDropdownMenuItem(
                              value: 'BOD1 - BOARD OF DIRECTOR',
                              label: 'BOD1 - BOARD OF DIRECTOR',
                            ),
                            AppDropdownMenuItem(
                              value: 'OPERATIONS',
                              label: 'OPERATIONS',
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _department = value),
                          validator: (value) =>
                              value == null ? 'Department is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: _personToVisit,
                          label: 'Person to Visit *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: [
                            AppDropdownMenuItem(value: 'Ryan', label: 'Ryan'),
                            AppDropdownMenuItem(value: 'Aisha', label: 'Aisha'),
                          ],
                          onChanged: (value) =>
                              setState(() => _personToVisit = value),
                          validator: (value) => value == null
                              ? 'Person to visit is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: _visitorType,
                          label: 'Visitor Type *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: [
                            AppDropdownMenuItem(
                              value: 'Visitor',
                              label: 'Visitor',
                            ),
                            AppDropdownMenuItem(
                              value: 'Contractor',
                              label: 'Contractor',
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _visitorType = value),
                          validator: (value) => value == null
                              ? 'Visitor type is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _purposeController,
                          label: 'Purpose *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Purpose is required.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('Visitor Information'),
                  isActive: _currentStep == 1,
                  content: Form(
                    key: _stepTwoFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextFormField(
                          controller: _companyController,
                          label: 'Company *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Company is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _contactController,
                          label: 'Contact Number *',
                          keyboardType: TextInputType.phone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Contact number is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _vehiclePlateController,
                          label: 'Vehicle Plate Number *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Vehicle plate number is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _dateFromController,
                          label: 'Visit Date From *',
                          readOnly: true,
                          suffixIcon: const Icon(Icons.calendar_today),
                          onTap: () =>
                              _pickDateTime(controller: _dateFromController),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Visit date from is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _dateToController,
                          label: 'Visit Date To *',
                          readOnly: true,
                          suffixIcon: const Icon(Icons.calendar_today),
                          onTap: () =>
                              _pickDateTime(controller: _dateToController),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Visit date to is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _projectController,
                          label: 'Project',
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _workDescriptionController,
                          label: 'Work Description',
                          minLines: 2,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: _workLevel,
                          label: 'Work Level',
                          items: [
                            AppDropdownMenuItem(value: 'Low', label: 'Low'),
                            AppDropdownMenuItem(
                              value: 'Medium',
                              label: 'Medium',
                            ),
                            AppDropdownMenuItem(value: 'High', label: 'High'),
                          ],
                          onChanged: (value) =>
                              setState(() => _workLevel = value),
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _remarkController,
                          label: 'Remark',
                          minLines: 2,
                          maxLines: 4,
                        ),
                      ],
                    ),
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
                      AppTextFormField(
                        controller: _visitorNameController,
                        focusNode: _visitorNameFocus,
                        label: 'Name (as per IC/Passport) *',
                      ),
                      const SizedBox(height: 12),
                      AppTextFormField(
                        controller: _visitorIdController,
                        label: 'IC/Passport Number *',
                      ),
                      const SizedBox(height: 12),
                      AppOutlinedButtonIcon(
                        onPressed: () {
                          showAppSnackBar(context, 'Photo capture mock.');
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Visitor Photo'),
                      ),
                      const SizedBox(height: 12),
                      AppOutlinedButtonIcon(
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
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 12),
                            AppOutlinedButtonIcon(
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
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
                                          showAppSnackBar(
                                            context,
                                            'Open both policy links before marking as read.',
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
                              AppOutlinedButtonIcon(
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
                                  AppOutlinedButton(
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
                              AppFilledButton(
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
                                  AppOutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Download uploaded'),
                                  ),
                                  AppOutlinedButton(
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
      ),
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
