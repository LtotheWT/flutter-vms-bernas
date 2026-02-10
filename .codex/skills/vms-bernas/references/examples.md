# Examples (vms_bernas)

- Example (from repo):
```dart
const String splashRoutePath = '/';
const String loginRoutePath = '/login';

final GoRouter appRouter = GoRouter(
  initialLocation: splashRoutePath,
  routes: [
    GoRoute(
      name: splashRouteName,
      path: splashRoutePath,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: loginRouteName,
      path: loginRoutePath,
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
```
- Example (from repo):
```dart
_timer = Timer(const Duration(seconds: 2), () {
  if (!mounted) {
    return;
  }
  context.go(loginRoutePath);
});
```
- Example (from repo):
```dart
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 120,
  });

  final String label;
  final String value;
  final double labelWidth;
```
- Example (from repo):
```dart
InfoRow(label: 'Status', value: item.status),
InfoRow(label: 'Purpose', value: item.purpose),
InfoRow(label: 'Company', value: item.company),
```
- Example (from repo):
```dart
AppTextFormField(
  controller: _userIdController,
  label: 'User ID',
  textInputAction: TextInputAction.next,
),
AppTextFormField(
  controller: _passwordController,
  obscureText: _obscurePassword,
  textInputAction: TextInputAction.done,
  label: 'Password',
),
```
- Example (from repo):
```dart
AppDropdownFormField<String>(
  value: formState.entity,
  label: 'Entity *',
  autovalidateMode: AutovalidateMode.onUserInteraction,
  items: [
    AppDropdownMenuItem(
      value: 'AGYTEK - Agytek1231',
      label: 'AGYTEK - Agytek1231',
    ),
  ],
  onChanged: ref
      .read(invitationAddControllerProvider.notifier)
      .updateEntity,
  validator: (value) => value == null ? 'Entity is required.' : null,
),
```
- Example (from repo):
```dart
final entityOptions = ref.watch(entityOptionsProvider);
final siteOptionsAsync = ref.watch(siteOptionsProvider(formState.entity));
final bool hasEntity = formState.entity != null;
final bool siteLoading = siteOptionsAsync.isLoading;
final bool siteEnabled = hasEntity && !siteLoading && !siteOptionsAsync.hasError;
final String? siteHelperText =
    !hasEntity ? 'Select entity first' : siteLoading ? 'Loading sites...' : null;
final List<String> siteOptions = siteOptionsAsync.maybeWhen(
  data: (data) => data,
  orElse: () => const [],
);
```
- Example (from repo):
```dart
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
    ref.read(invitationAddControllerProvider.notifier).updateEntity(value);
    ref.read(invitationAddControllerProvider.notifier).updateSite(null);
    _siteController.clear();
  },
  validator: (value) => value == null ? 'Entity is required.' : null,
),
```
- Example (from repo):
```dart
AppDropdownMenuFormField<String>(
  key: const ValueKey('Site'),
  controller: _siteController,
  initialSelection: formState.site,
  hintText: 'Site *',
  helperText: siteHelperText ?? 'Site *',
  autovalidateMode: AutovalidateMode.onUserInteraction,
  enabled: siteEnabled,
  entries: [
    for (final site in siteOptions)
      AppDropdownMenuEntry(value: site, label: site),
  ],
  onSelected: (value) {
    _siteTouched = true;
    ref.read(invitationAddControllerProvider.notifier).updateSite(value);
  },
  validator: (value) {
    if (!siteEnabled) return null;
    if (!_siteTouched) return null;
    return value == null ? 'Site is required.' : null;
  },
),
```
- Example (from repo):
```dart
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
```
- Example (from repo):
```dart
bool _validateStepForm(int step) {
  if (step == 0) {
    return _stepOneFormKey.currentState?.validate() ?? false;
  }
  if (step == 1) {
    return _stepTwoFormKey.currentState?.validate() ?? false;
  }
  return true;
}

onStepContinue: () {
  if (_currentStep == 0) {
    if (_validateStepForm(_currentStep)) {
      setState(() => _currentStep = 1);
    }
  } else {
    _submit();
  }
},
```
- Example (from repo):
```dart
final Set<String> _selectedIds = <String>{};

CheckboxListTile(
  value: _selectedIds.length == _visibleItems.length &&
      _visibleItems.isNotEmpty,
  onChanged: _visibleItems.isEmpty
      ? null
      : (checked) {
          setState(() {
            if (checked == true) {
              _selectedIds.addAll(
                _visibleItems.map((item) => item.invitationId),
              );
            } else {
              _selectedIds.clear();
            }
          });
        },
  title: Text(
    'Select all (${_selectedIds.length}/${_visibleItems.length})',
  ),
),
```
- Example (from repo):
```dart
AppOutlinedButtonIcon(
  onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
  icon: const Icon(Icons.delete_outline),
  label: Text(
    _selectedIds.isEmpty ? 'Delete' : 'Delete (${_selectedIds.length})',
  ),
),
```
- Example (from repo):
```dart
Text(
  widget.filter?.listTitle ?? 'Activity',
  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
),
const SizedBox(height: 8),
for (final item in filteredItems) _ActivityCard(item: item),
if (filteredItems.isEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      'No records to display.',
      textAlign: TextAlign.center,
      style: textTheme.bodySmall,
    ),
  ),
```
