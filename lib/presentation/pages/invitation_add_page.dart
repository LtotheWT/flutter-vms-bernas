import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  int _submitAttempt = 0;

  @override
  void dispose() {
    _companyController.dispose();
    _purposeController.dispose();
    _emailController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required ValueChanged<String> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;

    final value = '${picked.year}-${_two(picked.month)}-${_two(picked.day)}';
    controller.text = value;
    onSelected(value);
    setState(() {});
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

  bool _validateNonTextFields(InvitationAddState formState) {
    final missing = <String>[
      if (formState.entity == null) 'Entity',
      if (formState.site == null) 'Site',
      if (formState.department == null) 'Department',
      if (formState.personToVisit == null) 'Host',
      if (formState.visitorType == null) 'Visitor Type',
      if (_dateFromController.text.trim().isEmpty) 'Visit Date From',
      if (_dateToController.text.trim().isEmpty) 'Visit Date To',
    ];
    if (missing.isEmpty) return true;
    showAppSnackBar(context, '${missing.first} is required.');
    return false;
  }

  Future<void> _submit(InvitationAddState formState) async {
    setState(() => _submitAttempt += 1);
    final validText = _formKey.currentState?.validate() ?? false;
    final validSelection = _validateNonTextFields(formState);
    if (!validText || !validSelection) return;

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
    final entityOptions = ref.watch(entityOptionsProvider);
    final siteOptionsAsync = ref.watch(siteOptionsProvider(formState.entity));
    final siteOptions = siteOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <String>[],
    );
    final canPickSite =
        formState.entity != null &&
        !siteOptionsAsync.isLoading &&
        !siteOptionsAsync.hasError;

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
                        label: 'Entity',
                        value: formState.entity,
                        isRequired: true,
                        placeholder: 'Please select',
                        hasError:
                            _submitAttempt > 0 && formState.entity == null,
                        onTap: () async {
                          final selected = await _pickOption(
                            title: 'Entity',
                            options: entityOptions,
                            currentValue: formState.entity,
                          );
                          if (!mounted || selected == null) return;
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateEntity(selected);
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateSite(null);
                        },
                      ),
                      _SelectValueRow(
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
                        label: 'Department',
                        value: formState.department,
                        placeholder: 'Please select',
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 && formState.department == null,
                        onTap: () async {
                          final options = List.generate(
                            20,
                            (i) => 'Administration $i',
                          );
                          final selected = await _pickOption(
                            title: 'Department',
                            options: options,
                            currentValue: formState.department,
                          );
                          if (!mounted || selected == null) return;
                          ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDepartment(selected);
                        },
                      ),
                      _SelectValueRow(
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
                        label: 'Visitor Name',
                        isRequired: true,
                        controller: _companyController,
                        hintText: 'Please input',
                        onChanged: ref
                            .read(invitationAddControllerProvider.notifier)
                            .updateCompanyName,
                        validator: (value) =>
                            _requiredText(value, 'Visitor Name'),
                      ),
                      _TextInputRow(
                        label: 'Invitation Purpose',
                        isRequired: true,
                        controller: _purposeController,
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
                        label: 'Email',
                        isRequired: true,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Please input',
                        onChanged: ref
                            .read(invitationAddControllerProvider.notifier)
                            .updateEmail,
                        validator: (value) => _requiredText(value, 'Email'),
                      ),
                      _SelectValueRow(
                        label: 'Visit Date From',
                        value: _dateFromController.text.isEmpty
                            ? null
                            : _dateFromController.text,
                        placeholder: 'Please select',
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 &&
                            _dateFromController.text.trim().isEmpty,
                        onTap: () => _pickDate(
                          controller: _dateFromController,
                          onSelected: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDateFrom,
                        ),
                      ),
                      _SelectValueRow(
                        label: 'Visit Date To',
                        value: _dateToController.text.isEmpty
                            ? null
                            : _dateToController.text,
                        placeholder: 'Please select',
                        isRequired: true,
                        hasError:
                            _submitAttempt > 0 &&
                            _dateToController.text.trim().isEmpty,
                        onTap: () => _pickDate(
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
    required this.label,
    required this.isRequired,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
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
    required this.label,
    required this.placeholder,
    required this.isRequired,
    required this.onTap,
    this.value,
    this.enabled = true,
    this.hasError = false,
  });

  final String label;
  final String placeholder;
  final bool isRequired;
  final String? value;
  final bool enabled;
  final bool hasError;
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
        if (hasError)
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
