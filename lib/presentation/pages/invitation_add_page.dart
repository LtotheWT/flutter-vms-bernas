import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/department_option.dart';
import '../state/entity_option.dart';
import '../state/invitation_add_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/double_back_exit_scope.dart';
import '../widgets/loading_overlay.dart';

class InvitationAddPage extends ConsumerStatefulWidget {
  const InvitationAddPage({super.key});

  @override
  ConsumerState<InvitationAddPage> createState() => _InvitationAddPageState();
}

class _InvitationAddPageState extends ConsumerState<InvitationAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _companyFocusNode = FocusNode();
  final _purposeFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _entityRowKey = GlobalKey();
  final _siteRowKey = GlobalKey();
  final _departmentRowKey = GlobalKey();
  final _hostRowKey = GlobalKey();
  final _visitorTypeRowKey = GlobalKey();
  final _companyRowKey = GlobalKey();
  final _purposeRowKey = GlobalKey();
  final _emailRowKey = GlobalKey();
  final _dateFromRowKey = GlobalKey();
  final _dateToRowKey = GlobalKey();
  int _submitAttempt = 0;

  @override
  void dispose() {
    _companyController.dispose();
    _purposeController.dispose();
    _emailController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _companyFocusNode.dispose();
    _purposeFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required TextEditingController controller,
    required ValueChanged<String> onSelected,
  }) async {
    final now = DateTime.now();
    final initial = _parseDateTime(controller.text) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;

    final value =
        '${picked.year}-${_two(picked.month)}-${_two(picked.day)} '
        '${_two(pickedTime.hour)}:${_two(pickedTime.minute)}';
    controller.text = value;
    onSelected(value);
    setState(() {});
  }

  DateTime? _parseDateTime(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final normalized = text.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  Future<String?> _pickOption({
    required String title,
    required List<String> options,
    String? currentValue,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SearchableOptionSheet(
        title: title,
        options: options,
        currentValue: currentValue,
      ),
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _entityOptionLabel(EntityOption option) {
    return option.label.trim().isEmpty ? '(Blank)' : option.label;
  }

  String _departmentOptionLabel(DepartmentOption option) {
    return option.label.trim().isEmpty ? '(Blank)' : option.label;
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

  String _toDisplayError(Object error, {required String fallback}) {
    final text = error.toString().trim();
    if (text.startsWith('Exception:')) {
      return text.replaceFirst('Exception:', '').trim();
    }
    return text.isEmpty ? fallback : text;
  }

  bool _hasUnsavedChanges(InvitationAddState formState) {
    return _companyController.text.trim().isNotEmpty ||
        _purposeController.text.trim().isNotEmpty ||
        _emailController.text.trim().isNotEmpty ||
        _dateFromController.text.trim().isNotEmpty ||
        _dateToController.text.trim().isNotEmpty ||
        formState.entity != null ||
        formState.site != null ||
        formState.department != null ||
        formState.personToVisit != null ||
        formState.visitorType != null;
  }

  Future<void> _scrollToField(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      alignment: 0.1,
    );
  }

  Future<bool> _focusFirstInvalidField(InvitationAddState formState) async {
    if (formState.entity == null) {
      await _scrollToField(_entityRowKey);
      return false;
    }
    if (formState.site == null) {
      await _scrollToField(_siteRowKey);
      return false;
    }
    if (formState.department == null) {
      await _scrollToField(_departmentRowKey);
      return false;
    }
    if (formState.personToVisit == null) {
      await _scrollToField(_hostRowKey);
      return false;
    }
    if (formState.visitorType == null) {
      await _scrollToField(_visitorTypeRowKey);
      return false;
    }
    if (_companyController.text.trim().isEmpty) {
      await _scrollToField(_companyRowKey);
      _companyFocusNode.requestFocus();
      return false;
    }
    if (_purposeController.text.trim().isEmpty) {
      await _scrollToField(_purposeRowKey);
      _purposeFocusNode.requestFocus();
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      await _scrollToField(_emailRowKey);
      _emailFocusNode.requestFocus();
      return false;
    }
    if (_dateFromController.text.trim().isEmpty) {
      await _scrollToField(_dateFromRowKey);
      return false;
    }
    if (_dateToController.text.trim().isEmpty) {
      await _scrollToField(_dateToRowKey);
      return false;
    }
    return true;
  }

  Future<void> _submit(InvitationAddState formState) async {
    setState(() => _submitAttempt += 1);
    final validText = _formKey.currentState?.validate() ?? false;
    final validAll = await _focusFirstInvalidField(formState);
    if (!validText || !validAll) return;
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    await ref.read(invitationAddControllerProvider.notifier).submitMock();
    if (!mounted) return;
    showAppSnackBar(context, 'Invitation submitted.');
  }

  void _clearAll() {
    _formKey.currentState?.reset();
    _companyController.clear();
    _purposeController.clear();
    _emailController.clear();
    _dateFromController.clear();
    _dateToController.clear();
    ref.read(invitationAddControllerProvider.notifier).clear();
    setState(() => _submitAttempt = 0);
  }

  void _clearBasicInfo() {
    final notifier = ref.read(invitationAddControllerProvider.notifier);
    notifier.updateEntity(null);
    notifier.updateSite(null);
    notifier.updateDepartment(null);
    notifier.updatePersonToVisit(null);
    notifier.updateVisitorType(null);
    setState(() {});
  }

  void _clearVisitorInfo() {
    _companyController.clear();
    _purposeController.clear();
    ref.read(invitationAddControllerProvider.notifier).updateCompanyName('');
    ref.read(invitationAddControllerProvider.notifier).updatePurpose('');
    setState(() {});
  }

  void _clearScheduleAndContact() {
    _emailController.clear();
    _dateFromController.clear();
    _dateToController.clear();
    final notifier = ref.read(invitationAddControllerProvider.notifier);
    notifier.updateEmail('');
    notifier.updateDateFrom('');
    notifier.updateDateTo('');
    setState(() {});
  }

  String? _requiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formState = ref.watch(invitationAddControllerProvider);
    final entityOptionsAsync = ref.watch(entityOptionsProvider);
    final entityOptions = entityOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <EntityOption>[],
    );
    final entityDisplayValue = _selectedEntityLabel(
      options: entityOptions,
      selectedCode: formState.entity,
    );
    final entityLoadError = entityOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load entities. Tap to retry.',
      ),
    );
    final departmentOptionsAsync = ref.watch(
      departmentOptionsProvider(formState.entity),
    );
    final departmentOptions = departmentOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <DepartmentOption>[],
    );
    final departmentDisplayValue = _selectedDepartmentLabel(
      options: departmentOptions,
      selectedCode: formState.department,
    );
    final departmentLoadError = departmentOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load departments. Tap to retry.',
      ),
    );
    final siteOptionsAsync = ref.watch(siteOptionsProvider(formState.entity));
    final siteOptions = siteOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <String>[],
    );
    final canPickSite =
        formState.entity != null &&
        !siteOptionsAsync.isLoading &&
        !siteOptionsAsync.hasError;
    final canRetryDepartment =
        formState.entity != null && departmentOptionsAsync.hasError;
    final canPickDepartment =
        formState.entity != null &&
        !departmentOptionsAsync.isLoading &&
        !departmentOptionsAsync.hasError;
    final enableDepartmentField =
        formState.entity != null && !departmentOptionsAsync.isLoading;

    return DoubleBackExitScope(
      hasUnsavedChanges: _hasUnsavedChanges(formState),
      isBlocked: formState.isSubmitting,
      child: LoadingOverlay(
        isLoading: formState.isSubmitting,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Invitation Add'),
            actions: [
              TextButton(onPressed: _clearAll, child: const Text('Clear')),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppFilledButton(
              onPressed: () => _submit(formState),
              child: const Text('Send Invite'),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              autovalidateMode: _submitAttempt > 0
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  _FormSectionCard(
                    title: 'Basic Info',
                    onClear: _clearBasicInfo,
                    children: [
                      const _ReadOnlyValueRow(label: 'User', value: 'Ryan'),
                      _SelectValueRow(
                        key: _entityRowKey,
                        label: 'Entity',
                        value: entityDisplayValue,
                        isRequired: true,
                        placeholder: entityOptionsAsync.isLoading
                            ? 'Loading...'
                            : 'Please select',
                        helperText: entityLoadError,
                        hasError:
                            _submitAttempt > 0 &&
                            formState.entity == null &&
                            entityLoadError == null,
                        enabled: !entityOptionsAsync.isLoading,
                        onTap: () async {
                          if (entityOptionsAsync.hasError) {
                            ref.invalidate(entityOptionsProvider);
                            return;
                          }
                          if (entityOptions.isEmpty) return;

                          final selected = await _pickOption(
                            title: 'Entity',
                            options: entityOptions
                                .map(_entityOptionLabel)
                                .toList(growable: false),
                            currentValue: entityDisplayValue,
                          );
                          if (!mounted || selected == null) return;

                          final pickedOption = entityOptions.firstWhere(
                            (option) => _entityOptionLabel(option) == selected,
                            orElse: () =>
                                const EntityOption(value: '', label: ''),
                          );

                          final selectedValue =
                              pickedOption.value.trim().isEmpty
                              ? null
                              : pickedOption.value;

                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateEntity(selectedValue);
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateSite(null);
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDepartment(null);
                        },
                      ),
                      _SelectValueRow(
                        key: _siteRowKey,
                        label: 'Site',
                        value: formState.site,
                        placeholder: siteOptionsAsync.isLoading
                            ? 'Loading...'
                            : formState.entity == null
                            ? 'Select entity first'
                            : 'Please select',
                        isRequired: true,
                        enabled: canPickSite,
                        hasError:
                            _submitAttempt > 0 &&
                            canPickSite &&
                            formState.site == null,
                        onTap: () async {
                          if (!canPickSite) return;
                          final selected = await _pickOption(
                            title: 'Site',
                            options: siteOptions,
                            currentValue: formState.site,
                          );
                          if (!mounted || selected == null) return;
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateSite(selected);
                        },
                      ),
                      _SelectValueRow(
                        key: _departmentRowKey,
                        label: 'Department',
                        value: departmentDisplayValue,
                        placeholder: departmentOptionsAsync.isLoading
                            ? 'Loading...'
                            : formState.entity == null
                            ? 'Select entity first'
                            : 'Please select',
                        helperText: departmentLoadError,
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 &&
                            canPickDepartment &&
                            formState.department == null &&
                            departmentLoadError == null,
                        enabled: enableDepartmentField,
                        onTap: () async {
                          if (canRetryDepartment) {
                            ref.invalidate(
                              departmentOptionsProvider(formState.entity),
                            );
                            return;
                          }
                          if (!canPickDepartment || departmentOptions.isEmpty) {
                            return;
                          }

                          final selected = await _pickOption(
                            title: 'Department',
                            options: departmentOptions
                                .map(_departmentOptionLabel)
                                .toList(growable: false),
                            currentValue: departmentDisplayValue,
                          );
                          if (!mounted || selected == null) return;

                          final pickedOption = departmentOptions.firstWhere(
                            (option) =>
                                _departmentOptionLabel(option) == selected,
                            orElse: () =>
                                const DepartmentOption(value: '', label: ''),
                          );

                          final selectedValue =
                              pickedOption.value.trim().isEmpty
                              ? null
                              : pickedOption.value;

                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDepartment(selectedValue);
                        },
                      ),
                      _SelectValueRow(
                        key: _hostRowKey,
                        label: 'Host',
                        value: formState.personToVisit,
                        placeholder: 'Please select',
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 &&
                            formState.personToVisit == null,
                        onTap: () async {
                          final options = List.generate(20, (i) => 'Ryan $i');
                          final selected = await _pickOption(
                            title: 'Host',
                            options: options,
                            currentValue: formState.personToVisit,
                          );
                          if (!mounted || selected == null) return;
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePersonToVisit(selected);
                        },
                      ),
                      _SelectValueRow(
                        key: _visitorTypeRowKey,
                        label: 'Visitor Type',
                        value: formState.visitorType,
                        placeholder: 'Please select',
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 && formState.visitorType == null,
                        onTap: () async {
                          final options = List.generate(
                            20,
                            (i) => 'Visitor $i',
                          );
                          final selected = await _pickOption(
                            title: 'Visitor Type',
                            options: options,
                            currentValue: formState.visitorType,
                          );
                          if (!mounted || selected == null) return;
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateVisitorType(selected);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormSectionCard(
                    title: 'Visitor Info',
                    onClear: _clearVisitorInfo,
                    children: [
                      _TextInputRow(
                        key: _companyRowKey,
                        label: 'Visitor Name',
                        isRequired: true,
                        controller: _companyController,
                        focusNode: _companyFocusNode,
                        hintText: 'Please input',
                        onChanged: ref
                            .read(invitationAddControllerProvider.notifier)
                            .updateCompanyName,
                        validator: (value) =>
                            _requiredText(value, 'Visitor Name'),
                      ),
                      _TextInputRow(
                        key: _purposeRowKey,
                        label: 'Invitation Purpose',
                        isRequired: true,
                        controller: _purposeController,
                        focusNode: _purposeFocusNode,
                        hintText: 'Please input',
                        onChanged: ref
                            .read(invitationAddControllerProvider.notifier)
                            .updatePurpose,
                        validator: (value) =>
                            _requiredText(value, 'Invitation Purpose'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormSectionCard(
                    title: 'Schedule',
                    onClear: _clearScheduleAndContact,
                    children: [
                      _TextInputRow(
                        key: _emailRowKey,
                        label: 'Email',
                        isRequired: true,
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Please input',
                        onChanged: ref
                            .read(invitationAddControllerProvider.notifier)
                            .updateEmail,
                        validator: (value) => _requiredText(value, 'Email'),
                      ),
                      _SelectValueRow(
                        key: _dateFromRowKey,
                        label: 'Visit Date From',
                        value: _dateFromController.text.isEmpty
                            ? null
                            : _dateFromController.text,
                        placeholder: 'Please select',
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 &&
                            _dateFromController.text.trim().isEmpty,
                        onTap: () => _pickDateTime(
                          controller: _dateFromController,
                          onSelected: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDateFrom,
                        ),
                      ),
                      _SelectValueRow(
                        key: _dateToRowKey,
                        label: 'Visit Date To',
                        value: _dateToController.text.isEmpty
                            ? null
                            : _dateToController.text,
                        placeholder: 'Please select',
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 &&
                            _dateToController.text.trim().isEmpty,
                        onTap: () => _pickDateTime(
                          controller: _dateToController,
                          onSelected: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDateTo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Required fields are marked with *',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchableOptionSheet extends StatefulWidget {
  const _SearchableOptionSheet({
    required this.title,
    required this.options,
    this.currentValue,
  });

  final String title;
  final List<String> options;
  final String? currentValue;

  @override
  State<_SearchableOptionSheet> createState() => _SearchableOptionSheetState();
}

class _SearchableOptionSheetState extends State<_SearchableOptionSheet> {
  late final TextEditingController _searchController;
  late List<String> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredOptions = List<String>.from(widget.options);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredOptions = q.isEmpty
          ? List<String>.from(widget.options)
          : widget.options
                .where((item) => item.toLowerCase().contains(q))
                .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 320,
              child: _filteredOptions.isEmpty
                  ? const Center(child: Text('No results'))
                  : ListView.separated(
                      itemCount: _filteredOptions.length,
                      separatorBuilder: (_, _) => const _RowDivider(),
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        final selected = option == widget.currentValue;
                        return ListTile(
                          dense: true,
                          title: Text(option),
                          trailing: selected
                              ? Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({
    required this.title,
    required this.children,
    required this.onClear,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const _RowDivider(),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyValueRow extends StatelessWidget {
  const _ReadOnlyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label: label, isRequired: false),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        const _RowDivider(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TextInputRow extends StatelessWidget {
  const _TextInputRow({
    super.key,
    required this.label,
    required this.isRequired,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 6),
        const _RowDivider(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SelectValueRow extends StatelessWidget {
  const _SelectValueRow({
    super.key,
    required this.label,
    required this.placeholder,
    required this.isRequired,
    required this.onTap,
    this.value,
    this.enabled = true,
    this.hasError = false,
    this.helperText,
  });

  final String label;
  final String placeholder;
  final bool isRequired;
  final String? value;
  final bool enabled;
  final bool hasError;
  final String? helperText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayText = value ?? placeholder;
    final displayColor = value == null
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 4),
        InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      color: enabled
                          ? displayColor
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              helperText!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          )
        else if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '$label is required.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
        const SizedBox(height: 6),
        const _RowDivider(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.isRequired});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: colorScheme.error),
            ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(height: 1, thickness: 1, color: colorScheme.surface);
  }
}
