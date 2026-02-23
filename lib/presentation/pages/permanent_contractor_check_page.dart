import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/permanent_contractor_check_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/info_row.dart';
import '../widgets/labeled_form_rows.dart';

class PermanentContractorCheckPage extends ConsumerStatefulWidget {
  const PermanentContractorCheckPage({
    super.key,
    required this.initialCheckType,
  });

  final PermanentContractorCheckType initialCheckType;

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

  Future<void> _search() async {
    final controller = ref.read(
      permanentContractorCheckControllerProvider.notifier,
    );
    controller.updateSearchInput(_searchController.text);
    await controller.search();
  }

  Future<void> _pickCheckType(PermanentContractorCheckState state) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Check-In'),
                onTap: () => Navigator.of(context).pop('check_in'),
              ),
              ListTile(
                title: const Text('Check-Out'),
                onTap: () => Navigator.of(context).pop('check_out'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    ref
        .read(permanentContractorCheckControllerProvider.notifier)
        .setCheckType(
          selected == 'check_out'
              ? PermanentContractorCheckType.checkOut
              : PermanentContractorCheckType.checkIn,
        );
  }

  String _checkTypeLabel(PermanentContractorCheckType type) {
    return type == PermanentContractorCheckType.checkIn
        ? 'Check-In'
        : 'Check-Out';
  }

  String _formatDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = parsed.day.toString().padLeft(2, '0');
    final month = months[parsed.month - 1];
    final year = parsed.year.toString();
    return '$day/$month/$year';
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
                  LabeledSelectRow(
                    label: 'Check Type',
                    value: _checkTypeLabel(state.checkType),
                    placeholder: 'Please select',
                    onTap: () => _pickCheckType(state),
                  ),
                  LabeledFieldLabel(
                    label: 'Scan QR Code (ID)',
                    isRequired: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextInputField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          hintText: 'Please input',
                          onChanged: ref
                              .read(
                                permanentContractorCheckControllerProvider
                                    .notifier,
                              )
                              .updateSearchInput,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                _searchFocusNode.requestFocus();
                              },
                        tooltip: 'Scan QR',
                        icon: const Icon(Icons.qr_code_scanner),
                      ),
                    ],
                  ),
                  const FormRowDivider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppFilledButton(
                          onPressed: state.isLoading ? null : _search,
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
                        : _formatDate(state.info!.validWorkingDateFrom),
                  ),
                  InfoRow(
                    label: 'Valid Working Datetime To',
                    value: state.info == null
                        ? '-'
                        : _formatDate(state.info!.validWorkingDateTo),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
