import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_dropdown_menu_form_field.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/double_back_exit_scope.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/read_only_field.dart';
import '../state/invitation_add_providers.dart';

class InvitationAddPage extends ConsumerStatefulWidget {
  const InvitationAddPage({super.key});

  @override
  ConsumerState<InvitationAddPage> createState() => _InvitationAddPageState();
}

class _InvitationAddPageState extends ConsumerState<InvitationAddPage> {
  GlobalKey<FormState> _stepOneFormKey = GlobalKey<FormState>();
  final _stepTwoFormKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  final _entityController = TextEditingController();
  final _siteController = TextEditingController();
  final _departmentController = TextEditingController();
  final _personToVisitController = TextEditingController();
  final _visitorTypeController = TextEditingController();
  final _siteFieldKey = GlobalKey<FormFieldState<String>>();
  int _currentStep = 0;
  bool _siteTouched = false;

  @override
  void dispose() {
    _companyController.dispose();
    _purposeController.dispose();
    _emailController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _entityController.dispose();
    _siteController.dispose();
    _departmentController.dispose();
    _personToVisitController.dispose();
    _visitorTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required TextEditingController controller}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${_two(picked.month)}-${_two(picked.day)}';
    }
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void _clearForm() {
    _stepOneFormKey.currentState?.reset();
    _stepOneFormKey = GlobalKey<FormState>();
    _stepTwoFormKey.currentState?.reset();
    _companyController.clear();
    _purposeController.clear();
    _emailController.clear();
    _dateFromController.clear();
    _dateToController.clear();
    _entityController.clear();
    _siteController.clear();
    _departmentController.clear();
    _personToVisitController.clear();
    _visitorTypeController.clear();
    _siteTouched = false;
    ref.read(invitationAddControllerProvider.notifier).clear();
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
    await ref.read(invitationAddControllerProvider.notifier).submitMock();
    if (!mounted) {
      return;
    }
    showAppSnackBar(context, 'Invitation submitted.');
  }

  Future<void> _confirmClear() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear form?'),
        content: const Text('This will clear all fields in both steps.'),
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formState = ref.watch(invitationAddControllerProvider);
    final entityOptions = ref.watch(entityOptionsProvider);
    final siteOptionsAsync = ref.watch(siteOptionsProvider(formState.entity));
    final bool hasEntity = formState.entity != null;
    final bool siteLoading = siteOptionsAsync.isLoading;
    final bool siteEnabled =
        hasEntity && !siteLoading && !siteOptionsAsync.hasError;
    final String? siteHelperText = !hasEntity
        ? 'Select entity first'
        : siteLoading
        ? 'Loading sites...'
        : null;
    final List<String> siteOptions = siteOptionsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const [],
    );

    return DoubleBackExitScope(
      hasUnsavedChanges: _hasUnsavedChanges(formState),
      isBlocked: formState.isSubmitting,
      child: LoadingOverlay(
        isLoading: formState.isSubmitting,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Invitation Add'),
            actions: [
              TextButton(
                onPressed: () => _confirmClear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          body: SafeArea(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0) {
                  if (_validateStepForm(_currentStep)) {
                    setState(() => _currentStep = 1);
                  }
                } else {
                  _submit();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep = _currentStep - 1);
                }
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
              controlsBuilder: (context, details) {
                final isLast = _currentStep == 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppFilledButton(
                          onPressed: details.onStepContinue,
                          child: Text(isLast ? 'Send Invite' : 'Next'),
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
              steps: [
                Step(
                  title: Text('Step 1'),
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
                        const ReadOnlyField(label: 'User Name', value: 'Ryan'),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),

                        AppDropdownMenuFormField<String>(
                          key: const ValueKey('Entity'),
                          controller: _entityController,
                          initialSelection: formState.entity,
                          hintText: 'Entity *',
                          helperText: 'Entity *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          entries: [
                            for (final entity in entityOptions)
                              AppDropdownMenuEntry(
                                value: entity,
                                label: entity,
                              ),
                          ],
                          onSelected: (value) {
                            ref
                                .read(invitationAddControllerProvider.notifier)
                                .updateEntity(value);
                            ref
                                .read(invitationAddControllerProvider.notifier)
                                .updateSite(null);
                            _siteController.clear();
                            _siteFieldKey.currentState?.reset();
                            setState(() {
                              _siteTouched = false;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Entity is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownMenuFormField<String>(
                          key: _siteFieldKey,
                          controller: _siteController,
                          initialSelection: formState.site,
                          hintText: 'Site *',
                          helperText: siteHelperText ?? 'Site *',
                          autovalidateMode: _siteTouched
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          enabled: siteEnabled,
                          entries: [
                            for (final site in siteOptions)
                              AppDropdownMenuEntry(value: site, label: site),
                          ],
                          onSelected: (value) {
                            _siteTouched = true;
                            ref
                                .read(invitationAddControllerProvider.notifier)
                                .updateSite(value);
                          },
                          validator: (value) {
                            if (!siteEnabled) return null;
                            if (!_siteTouched) return null;
                            return value == null ? 'Site is required.' : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppDropdownMenuFormField<String>(
                          key: ValueKey("Department"),
                          controller: _departmentController,
                          initialSelection: formState.department,
                          hintText: 'Department *',
                          helperText: 'Department *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          entries: List.generate(20, (i) {
                            return AppDropdownMenuEntry(
                              value: 'Administration $i',
                              label: 'Administration $i',
                            );
                          }),
                          // entries: [
                          //   AppDropdownMenuEntry(
                          //     value: 'Administration',
                          //     label: 'Administration',
                          //   ),
                          //   AppDropdownMenuEntry(
                          //     value: 'Operations',
                          //     label: 'Operations',
                          //   ),
                          // ],
                          onSelected: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDepartment,
                          validator: (value) =>
                              value == null ? 'Department is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownMenuFormField<String>(
                          controller: _personToVisitController,
                          initialSelection: formState.personToVisit,
                          hintText: 'Person to Visit *',
                          helperText: 'Person to Visit *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          entries: List.generate(20, (i) {
                            return AppDropdownMenuEntry(
                              value: 'Ryan $i',
                              label: 'Ryan $i',
                            );
                          }),
                          // entries: [
                          //   AppDropdownMenuEntry(value: 'Ryan', label: 'Ryan'),
                          //   AppDropdownMenuEntry(
                          //     value: 'Aisha',
                          //     label: 'Aisha',
                          //   ),
                          // ],
                          onSelected: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePersonToVisit,
                          validator: (value) => value == null
                              ? 'Person to visit is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        AppDropdownMenuFormField<String>(
                          controller: _visitorTypeController,
                          initialSelection: formState.visitorType,
                          hintText: 'Visitor Type *',
                          helperText: 'Visitor Type *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          entries: List.generate(20, (i) {
                            return AppDropdownMenuEntry(
                              value: 'Visitor $i',
                              label: 'Visitor $i',
                            );
                          }),
                          // entries: [
                          //   AppDropdownMenuEntry(
                          //     value: 'Visitor',
                          //     label: 'Visitor',
                          //   ),
                          //   AppDropdownMenuEntry(
                          //     value: 'Contractor',
                          //     label: 'Contractor',
                          //   ),
                          // ],
                          onSelected: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateVisitorType,
                          validator: (value) => value == null
                              ? 'Visitor type is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _companyController,
                          label: 'Company/Visitor Name *',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateCompanyName,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Company/visitor name is required.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('Step 2'),
                  isActive: _currentStep == 1,
                  content: Form(
                    key: _stepTwoFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextFormField(
                          controller: _purposeController,
                          label: 'Invitation Purpose *',
                          minLines: 3,
                          maxLines: 5,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePurpose,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Invitation purpose is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _emailController,
                          label: 'Send Invitation To (Email) *',
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateEmail,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Email is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextFormField(
                          controller: _dateFromController,
                          label: 'Visit Date From *',
                          readOnly: true,
                          suffixIcon: const Icon(Icons.calendar_today),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onTap: () =>
                              _pickDate(controller: _dateFromController).then((
                                _,
                              ) {
                                ref
                                    .read(
                                      invitationAddControllerProvider.notifier,
                                    )
                                    .updateDateFrom(_dateFromController.text);
                              }),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onTap: () => _pickDate(controller: _dateToController)
                              .then((_) {
                                ref
                                    .read(
                                      invitationAddControllerProvider.notifier,
                                    )
                                    .updateDateTo(_dateToController.text);
                              }),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Visit date to is required.'
                              : null,
                        ),
                      ],
                    ),
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
