import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_time_formats.dart';
import '../services/mobile_scanner_launcher.dart';
import '../state/permanent_contractor_check_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/check_type_segmented_control.dart';
import '../widgets/info_row.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/remote_photo_slot.dart';

class PermanentContractorCheckPage extends ConsumerStatefulWidget {
  const PermanentContractorCheckPage({
    super.key,
    required this.initialCheckType,
    this.scanLauncher,
  });

  final PermanentContractorCheckType initialCheckType;
  final Future<String?> Function(BuildContext context)? scanLauncher;

  @override
  ConsumerState<PermanentContractorCheckPage> createState() =>
      _PermanentContractorCheckPageState();
}

class _PermanentContractorCheckPageState
    extends ConsumerState<PermanentContractorCheckPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final ProviderSubscription<PermanentContractorCheckState>
  _stateSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = ref.listenManual<PermanentContractorCheckState>(
      permanentContractorCheckControllerProvider,
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
          .read(permanentContractorCheckControllerProvider.notifier)
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
    final controller = ref.read(
      permanentContractorCheckControllerProvider.notifier,
    );
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

  Future<void> _confirm(PermanentContractorCheckState state) async {
    final hasInfo = state.info?.contractorId.trim().isNotEmpty == true;
    if (!hasInfo) {
      showAppSnackBar(context, 'Please search contractor info before submit.');
      return;
    }

    final controller = ref.read(
      permanentContractorCheckControllerProvider.notifier,
    );
    final result = state.checkType == PermanentContractorCheckType.checkIn
        ? await controller.submitCheckIn()
        : await controller.submitCheckOut();
    if (!mounted) {
      return;
    }

    final fallbackMessage =
        state.checkType == PermanentContractorCheckType.checkIn
        ? 'Checked-in successfully.'
        : 'Checked-out successfully.';
    showAppSnackBar(
      context,
      result.message.trim().isEmpty ? fallbackMessage : result.message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permanentContractorCheckControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Permanent Contractor Check-In/Out')),
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
                    'Search Contractor',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckTypeSegmentedControl(
                    isCheckIn:
                        state.checkType == PermanentContractorCheckType.checkIn,
                    onChanged: (isCheckIn) {
                      ref
                          .read(
                            permanentContractorCheckControllerProvider.notifier,
                          )
                          .setCheckType(
                            isCheckIn
                                ? PermanentContractorCheckType.checkIn
                                : PermanentContractorCheckType.checkOut,
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
                        .read(
                          permanentContractorCheckControllerProvider.notifier,
                        )
                        .updateSearchInput,
                    suffixIcon: CompactSuffixTapIcon(
                      key: const Key('permanent-contractor-scan-button'),
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
                    'Permanent Contractor Info',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RemotePhotoSlot(
                      thumbnailKey: const Key(
                        'permanent-contractor-photo-thumbnail',
                      ),
                      fullscreenKey: const Key(
                        'permanent-contractor-photo-fullscreen',
                      ),
                      asyncBytes: ref.watch(
                        permanentContractorImageProvider(
                          PermanentContractorPhotoKey(
                            contractorId: state.info?.contractorId ?? '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InfoRow(
                    label: 'Permanent Contractor ID',
                    value: state.info?.contractorId.trim().isNotEmpty == true
                        ? state.info!.contractorId
                        : '-',
                  ),
                  InfoRow(
                    label: 'Permanent Contractor Name',
                    value: state.info?.contractorName.trim().isNotEmpty == true
                        ? state.info!.contractorName
                        : '-',
                  ),
                  InfoRow(
                    label: 'IC/Passport Number',
                    value: state.info?.contractorIc.trim().isNotEmpty == true
                        ? state.info!.contractorIc
                        : '-',
                  ),
                  InfoRow(
                    label: 'Handphone No',
                    value: state.info?.hpNo.trim().isNotEmpty == true
                        ? state.info!.hpNo
                        : '-',
                  ),
                  InfoRow(
                    label: 'Email',
                    value: state.info?.email.trim().isNotEmpty == true
                        ? state.info!.email
                        : '-',
                  ),
                  InfoRow(
                    label: 'Company Name',
                    value: state.info?.company.trim().isNotEmpty == true
                        ? state.info!.company
                        : '-',
                  ),
                  InfoRow(
                    label: 'Valid Working Datetime From',
                    value: state.info == null
                        ? '-'
                        : formatDateOnlyOrRaw(state.info!.validWorkingDateFrom),
                  ),
                  InfoRow(
                    label: 'Valid Working Datetime To',
                    value: state.info == null
                        ? '-'
                        : formatDateOnlyOrRaw(state.info!.validWorkingDateTo),
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
                  state.info?.contractorId.trim().isNotEmpty == true
              ? () => _confirm(state)
              : null,
          child: state.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  state.checkType == PermanentContractorCheckType.checkIn
                      ? 'Confirm Check-In'
                      : 'Confirm Check-Out',
                ),
        ),
      ),
    );
  }
}
