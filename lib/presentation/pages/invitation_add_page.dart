import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/department_option.dart';
import '../state/entity_option.dart';
import '../state/host_option.dart';
import '../state/invitation_add_providers.dart';
import '../state/site_option.dart';
import '../state/visitor_type_option.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/searchable_option_sheet.dart';
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
    return showSearchableOptionSheet(
      context: context,
      title: title,
      options: options,
      currentValue: currentValue,
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _entityOptionLabel(EntityOption option) {
    return option.label.trim().isEmpty ? '(Blank)' : option.label;
  }

  String _departmentOptionLabel(DepartmentOption option) {
    return option.label.trim().isEmpty ? '(Blank)' : option.label;
  }

  String _siteOptionLabel(SiteOption option) {
    final label = option.label.trim();
    if (label.isNotEmpty) {
      return label;
    }
    return option.value.trim().isEmpty ? '(Blank)' : option.value;
  }

  String _hostOptionLabel(HostOption option) {
    final employeeId = option.value.trim();
    final employeeName = option.label.trim();
    if (employeeName.isNotEmpty && employeeId.isNotEmpty) {
      return '$employeeName ($employeeId)';
    }
    if (employeeName.isNotEmpty) {
      return employeeName;
    }
    return employeeId.isEmpty ? '(Blank)' : employeeId;
  }

  String _visitorTypeOptionLabel(VisitorTypeOption option) {
    final typeDesc = option.label.trim();
    if (typeDesc.isNotEmpty) {
      return typeDesc;
    }
    final visitorType = option.value.trim();
    return visitorType.isEmpty ? '(Blank)' : visitorType;
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

  String? _selectedHostLabel({
    required List<HostOption> options,
    required String? selectedCode,
  }) {
    if (selectedCode == null) return null;
    for (final option in options) {
      if (option.value == selectedCode) {
        return _hostOptionLabel(option);
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
    final result = await ref
        .read(invitationAddControllerProvider.notifier)
        .submit();
    if (!mounted) return;
    showAppSnackBar(context, result.message);
    if (result.success) {
      _clearAll();
    }
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
      orElse: () => const <SiteOption>[],
    );
    final siteDisplayValue = _selectedSiteLabel(
      options: siteOptions,
      selectedCode: formState.site,
    );
    final siteLoadError = siteOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load sites. Tap to retry.',
      ),
    );
    final hostLookupParams = HostLookupParams(
      entity: formState.entity,
      site: formState.site,
      department: formState.department,
    );
    final hostOptionsAsync = ref.watch(hostOptionsProvider(hostLookupParams));
    final hostOptions = hostOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <HostOption>[],
    );
    final hostDisplayValue = _selectedHostLabel(
      options: hostOptions,
      selectedCode: formState.personToVisit,
    );
    final hostLoadError = hostOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load hosts. Tap to retry.',
      ),
    );
    final visitorTypeOptionsAsync = ref.watch(visitorTypeOptionsProvider);
    final visitorTypeOptions = visitorTypeOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <VisitorTypeOption>[],
    );
    final visitorTypeDisplayValue = _selectedVisitorTypeLabel(
      options: visitorTypeOptions,
      selectedCode: formState.visitorType,
    );
    final visitorTypeLoadError = visitorTypeOptionsAsync.whenOrNull(
      error: (error, _) => _toDisplayError(
        error,
        fallback: 'Failed to load visitor types. Tap to retry.',
      ),
    );
    final canRetrySite = formState.entity != null && siteOptionsAsync.hasError;
    final canPickSite =
        formState.entity != null &&
        !siteOptionsAsync.isLoading &&
        !siteOptionsAsync.hasError;
    final enableSiteField =
        formState.entity != null && !siteOptionsAsync.isLoading;
    final canRetryDepartment =
        formState.entity != null && departmentOptionsAsync.hasError;
    final canPickDepartment =
        formState.entity != null &&
        !departmentOptionsAsync.isLoading &&
        !departmentOptionsAsync.hasError;
    final enableDepartmentField =
        formState.entity != null && !departmentOptionsAsync.isLoading;
    final isHostDependencyReady =
        formState.entity != null &&
        formState.site != null &&
        formState.department != null;
    final canRetryHost = isHostDependencyReady && hostOptionsAsync.hasError;
    final canPickHost =
        isHostDependencyReady &&
        !hostOptionsAsync.isLoading &&
        !hostOptionsAsync.hasError;
    final enableHostField =
        isHostDependencyReady && !hostOptionsAsync.isLoading;
    final canPickVisitorType =
        !visitorTypeOptionsAsync.isLoading && !visitorTypeOptionsAsync.hasError;

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
                      LabeledSelectRow(
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
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePersonToVisit(null);
                        },
                      ),
                      LabeledSelectRow(
                        key: _siteRowKey,
                        label: 'Site',
                        value: siteDisplayValue,
                        placeholder: siteOptionsAsync.isLoading
                            ? 'Loading...'
                            : formState.entity == null
                            ? 'Select entity first'
                            : 'Please select',
                        helperText: siteLoadError,
                        isRequired: true,
                        enabled: enableSiteField,
                        hasError:
                            _submitAttempt > 0 &&
                            canPickSite &&
                            formState.site == null &&
                            siteLoadError == null,
                        onTap: () async {
                          if (canRetrySite) {
                            ref.invalidate(
                              siteOptionsProvider(formState.entity),
                            );
                            return;
                          }
                          if (!canPickSite || siteOptions.isEmpty) return;
                          final selected = await _pickOption(
                            title: 'Site',
                            options: siteOptions
                                .map(_siteOptionLabel)
                                .toList(growable: false),
                            currentValue: siteDisplayValue,
                          );
                          if (!mounted || selected == null) return;

                          final pickedOption = siteOptions.firstWhere(
                            (option) => _siteOptionLabel(option) == selected,
                            orElse: () =>
                                const SiteOption(value: '', label: ''),
                          );

                          final selectedValue =
                              pickedOption.value.trim().isEmpty
                              ? null
                              : pickedOption.value;

                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateSite(selectedValue);
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePersonToVisit(null);
                        },
                      ),
                      LabeledSelectRow(
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
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePersonToVisit(null);
                        },
                      ),
                      LabeledSelectRow(
                        key: _hostRowKey,
                        label: 'Host',
                        value: hostDisplayValue,
                        placeholder: hostOptionsAsync.isLoading
                            ? 'Loading...'
                            : !isHostDependencyReady
                            ? 'Select entity, site and department first'
                            : 'Please select',
                        helperText: hostLoadError,
                        isRequired: true,
                        enabled: enableHostField,
                        hasError:
                            _submitAttempt > 0 &&
                            canPickHost &&
                            formState.personToVisit == null &&
                            hostLoadError == null,
                        onTap: () async {
                          if (canRetryHost) {
                            ref.invalidate(
                              hostOptionsProvider(hostLookupParams),
                            );
                            return;
                          }
                          if (!canPickHost || hostOptions.isEmpty) return;
                          final selected = await _pickOption(
                            title: 'Host',
                            options: hostOptions
                                .map(_hostOptionLabel)
                                .toList(growable: false),
                            currentValue: hostDisplayValue,
                          );
                          if (!mounted || selected == null) return;

                          final pickedOption = hostOptions.firstWhere(
                            (option) => _hostOptionLabel(option) == selected,
                            orElse: () =>
                                const HostOption(value: '', label: ''),
                          );
                          final selectedValue =
                              pickedOption.value.trim().isEmpty
                              ? null
                              : pickedOption.value;
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePersonToVisit(selectedValue);
                        },
                      ),
                      LabeledSelectRow(
                        key: _visitorTypeRowKey,
                        label: 'Visitor Type',
                        value: visitorTypeDisplayValue,
                        placeholder: visitorTypeOptionsAsync.isLoading
                            ? 'Loading...'
                            : 'Please select',
                        helperText: visitorTypeLoadError,
                        isRequired: true,
                        enabled: !visitorTypeOptionsAsync.isLoading,
                        hasError:
                            _submitAttempt > 0 &&
                            canPickVisitorType &&
                            formState.visitorType == null &&
                            visitorTypeLoadError == null,
                        onTap: () async {
                          if (visitorTypeOptionsAsync.hasError) {
                            ref.invalidate(visitorTypeOptionsProvider);
                            return;
                          }
                          if (!canPickVisitorType ||
                              visitorTypeOptions.isEmpty) {
                            return;
                          }
                          final selected = await _pickOption(
                            title: 'Visitor Type',
                            options: visitorTypeOptions
                                .map(_visitorTypeOptionLabel)
                                .toList(growable: false),
                            currentValue: visitorTypeDisplayValue,
                          );
                          if (!mounted || selected == null) return;

                          final pickedOption = visitorTypeOptions.firstWhere(
                            (option) =>
                                _visitorTypeOptionLabel(option) == selected,
                            orElse: () =>
                                const VisitorTypeOption(value: '', label: ''),
                          );
                          final selectedValue =
                              pickedOption.value.trim().isEmpty
                              ? null
                              : pickedOption.value;
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateVisitorType(selectedValue);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormSectionCard(
                    title: 'Visitor Info',
                    onClear: _clearVisitorInfo,
                    children: [
                      LabeledTextInputRow(
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
                      LabeledTextInputRow(
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
                      LabeledTextInputRow(
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
                      LabeledSelectRow(
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
                      LabeledSelectRow(
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
            const FormRowDivider(),
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
        LabeledFieldLabel(label: label, isRequired: false),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        const FormRowDivider(),
        const SizedBox(height: 8),
      ],
    );
  }
}
