import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_dropdown_form_field.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _companyController.dispose();
    _purposeController.dispose();
    _emailController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
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
    _formKey.currentState?.reset();
    _companyController.clear();
    _purposeController.clear();
    _emailController.clear();
    _dateFromController.clear();
    _dateToController.clear();
    ref.read(invitationAddControllerProvider.notifier).clear();
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    await ref.read(invitationAddControllerProvider.notifier).submitMock();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invitation submitted.')));
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
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep == 0) {
                    setState(() => _currentStep = 1);
                  } else {
                    _submit();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep = _currentStep - 1);
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
                    title: const Text('Visitor & Host'),
                    isActive: _currentStep == 0,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'All fields with an asterisk (*) are mandatory.',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        const ReadOnlyField(label: 'User Name', value: 'Ryan'),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: formState.entity,
                          label: 'Entity *',
                          items: [
                            AppDropdownMenuItem(
                              value: 'AGYTEK - Agytek1231',
                              label: 'AGYTEK - Agytek1231',
                            ),
                          ],
                          onChanged: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateEntity,
                          validator: (value) =>
                              value == null ? 'Entity is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: formState.site,
                          label: 'Site *',
                          items: [
                            AppDropdownMenuItem(
                              value: 'FACTORY1 - FACTORY1 T',
                              label: 'FACTORY1 - FACTORY1 T',
                            ),
                          ],
                          onChanged: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateSite,
                          validator: (value) =>
                              value == null ? 'Site is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: formState.department,
                          label: 'Department *',
                          items: [
                            AppDropdownMenuItem(
                              value: 'Administration',
                              label: 'Administration',
                            ),
                            AppDropdownMenuItem(
                              value: 'Operations',
                              label: 'Operations',
                            ),
                          ],
                          onChanged: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updateDepartment,
                          validator: (value) =>
                              value == null ? 'Department is required.' : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: formState.personToVisit,
                          label: 'Person to Visit *',
                          items: [
                            AppDropdownMenuItem(value: 'Ryan', label: 'Ryan'),
                            AppDropdownMenuItem(value: 'Aisha', label: 'Aisha'),
                          ],
                          onChanged: ref
                              .read(invitationAddControllerProvider.notifier)
                              .updatePersonToVisit,
                          validator: (value) => value == null
                              ? 'Person to visit is required.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppDropdownFormField<String>(
                          value: formState.visitorType,
                          label: 'Visitor Type *',
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
                          onChanged: ref
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
                  Step(
                    title: const Text('Invitation Details'),
                    isActive: _currentStep == 1,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextFormField(
                          controller: _purposeController,
                          label: 'Invitation Purpose *',
                          minLines: 3,
                          maxLines: 5,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
