import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_time_formats.dart';
import '../services/mobile_scanner_launcher.dart';
import '../state/employee_check_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/check_type_segmented_control.dart';
import '../widgets/info_row.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/remote_photo_slot.dart';

class EmployeeCheckPage extends ConsumerStatefulWidget {
  const EmployeeCheckPage({
    super.key,
    required this.initialCheckType,
    this.scanLauncher,
  });

  final EmployeeCheckType initialCheckType;
  final Future<String?> Function(BuildContext context)? scanLauncher;

  @override
  ConsumerState<EmployeeCheckPage> createState() => _EmployeeCheckPageState();
}

class _EmployeeCheckPageState extends ConsumerState<EmployeeCheckPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final ProviderSubscription<EmployeeCheckState> _stateSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = ref.listenManual<EmployeeCheckState>(
      employeeCheckControllerProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }
        if (_searchController.text != next.searchInput) {
          _searchController.value = TextEditingValue(
            text: next.searchInput,
            selection: TextSelection.collapsed(offset: next.searchInput.length),
          );
        }
      },
      fireImmediately: true,
    );

    Future<void>.microtask(() {
      ref
          .read(employeeCheckControllerProvider.notifier)
          .setCheckType(widget.initialCheckType);
    });
  }

  @override
  void dispose() {
    _stateSubscription.close();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _search({String? overrideCode}) async {
    final value = overrideCode ?? _searchController.text;
    final controller = ref.read(employeeCheckControllerProvider.notifier);
    controller.updateSearchInput(value);
    await controller.search();
  }

  Future<void> _openScannerAndSearch() async {
    final scannerResult = await openMobileScanner(
      context: context,
      title: 'Scan QR Code',
      description: 'Align QR code inside the frame to scan.',
      overrideLauncher: widget.scanLauncher,
    );

    final scanned = scannerResult?.trim() ?? '';
    if (scanned.isEmpty || !mounted) {
      return;
    }
    await _search(overrideCode: scanned);
  }

  Future<void> _confirm(EmployeeCheckState state) async {
    final hasInfo = state.info?.employeeId.trim().isNotEmpty == true;
    if (!hasInfo) {
      showAppSnackBar(context, 'Please search employee info before submit.');
      return;
    }

    final result = await ref
        .read(employeeCheckControllerProvider.notifier)
        .submit();
    if (!mounted) {
      return;
    }

    final fallbackMessage = state.checkType == EmployeeCheckType.checkOut
        ? 'Employee checked out successfully.'
        : 'Employee checked in successfully.';
    final message = result.message.trim().isNotEmpty
        ? result.message.trim()
        : fallbackMessage;
    showAppSnackBar(context, message);
  }

  String _displayOrDash(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeCheckControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Check-In/Out')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Search Employee',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckTypeSegmentedControl(
                    isCheckIn: state.checkType == EmployeeCheckType.checkIn,
                    onChanged: (isCheckIn) {
                      ref
                          .read(employeeCheckControllerProvider.notifier)
                          .setCheckType(
                            isCheckIn
                                ? EmployeeCheckType.checkIn
                                : EmployeeCheckType.checkOut,
                          );
                    },
                  ),
                  const SizedBox(height: 8),
                  LabeledTextInputRow(
                    label: 'Scan QR Code (ID)',
                    isRequired: true,
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: 'Please input',
                    onChanged: ref
                        .read(employeeCheckControllerProvider.notifier)
                        .updateSearchInput,
                    suffixIcon: CompactSuffixTapIcon(
                      key: const Key('employee-scan-button'),
                      icon: Icons.qr_code_scanner,
                      enabled: !(state.isLoading || state.isSubmitting),
                      onTap: _openScannerAndSearch,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppFilledButton(
                          onPressed: state.isLoading || state.isSubmitting
                              ? null
                              : _search,
                          fullWidth: true,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Search'),
                        ),
                      ),
                    ],
                  ),
                  if (state.errorMessage != null &&
                      state.errorMessage!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
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
                    'Employee Info',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RemotePhotoSlot(
                      thumbnailKey: const Key('employee-photo-thumbnail'),
                      fullscreenKey: const Key('employee-photo-fullscreen'),
                      asyncBytes: ref.watch(
                        employeeImageProvider(
                          EmployeePhotoKey(
                            employeeId: state.info?.employeeId ?? '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InfoRow(
                    label: 'Employee ID',
                    value: _displayOrDash(state.info?.employeeId),
                  ),
                  InfoRow(
                    label: 'Employee Name',
                    value: _displayOrDash(state.info?.employeeName),
                  ),
                  InfoRow(
                    label: 'Site',
                    value: _displayOrDash(state.info?.site),
                  ),
                  InfoRow(
                    label: 'Department',
                    value: _displayOrDash(state.info?.department),
                  ),
                  InfoRow(
                    label: 'Unit',
                    value: _displayOrDash(state.info?.unit),
                  ),
                  InfoRow(
                    label: 'Vehicle Type',
                    value: _displayOrDash(state.info?.vehicleType),
                  ),
                  InfoRow(
                    label: 'Handphone No',
                    value: _displayOrDash(state.info?.handphoneNo),
                  ),
                  InfoRow(
                    label: 'Tel No and Extension',
                    value: _displayOrDash(state.info?.telNoExtension),
                  ),
                  InfoRow(
                    label: 'Effective Working Date',
                    value: state.info == null
                        ? '-'
                        : formatDateOnlyOrRaw(state.info!.effectiveWorkingDate),
                  ),
                  InfoRow(
                    label: 'Last Working Date',
                    value: state.info == null
                        ? '-'
                        : formatDateOnlyOrRaw(state.info!.lastWorkingDate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: AppFilledButton(
          onPressed:
              !state.isLoading &&
                  !state.isSubmitting &&
                  state.info?.employeeId.trim().isNotEmpty == true
              ? () => _confirm(state)
              : null,
          child: state.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  state.checkType == EmployeeCheckType.checkOut
                      ? 'Confirm Check-Out'
                      : 'Confirm Check-In',
                ),
        ),
      ),
    );
  }
}
