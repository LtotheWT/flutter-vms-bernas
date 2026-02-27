import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_bernas/presentation/widgets/labeled_form_rows.dart';

import '../../domain/entities/visitor_check_in_submission_entity.dart';
import '../../domain/entities/visitor_check_in_submission_item_entity.dart';
import '../../domain/entities/visitor_lookup_item_entity.dart';
import 'mobile_scanner_page.dart';
import '../state/auth_session_providers.dart';
import '../state/visitor_check_in_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/info_row.dart';
import '../widgets/remote_photo_slot.dart';
import '../widgets/app_snackbar.dart';

class VisitorCheckInPage extends ConsumerStatefulWidget {
  const VisitorCheckInPage({
    super.key,
    required this.isCheckIn,
    this.scanLauncher,
    this.physicalTagScanLauncher,
  });

  final bool isCheckIn;
  final Future<String?> Function(BuildContext context)? scanLauncher;
  final Future<String?> Function(BuildContext context)? physicalTagScanLauncher;

  @override
  ConsumerState<VisitorCheckInPage> createState() => _VisitorCheckInPageState();
}

class _VisitorCheckInPageState extends ConsumerState<VisitorCheckInPage> {
  final _scanController = TextEditingController();
  final _scanFocusNode = FocusNode();
  final Set<int> _selectedIndexes = <int>{};
  final Map<String, String> _physicalTagDraftByAppId = <String, String>{};
  final Map<String, TextEditingController> _physicalTagControllerByAppId =
      <String, TextEditingController>{};
  int _resultTabIndex = 0;
  String _lastLookupCode = '';
  late final ProviderSubscription<VisitorCheckState> _stateSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = ref.listenManual<VisitorCheckState>(
      visitorCheckControllerProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }

        if (_scanController.text != next.searchInput) {
          _scanController.value = TextEditingValue(
            text: next.searchInput,
            selection: TextSelection.collapsed(offset: next.searchInput.length),
          );
        }

        final hadLookup = previous?.lookup != null;
        final hasLookup = next.lookup != null;
        if (hadLookup != hasLookup || previous?.lookup != next.lookup) {
          for (final controller in _physicalTagControllerByAppId.values) {
            controller.dispose();
          }
          setState(() {
            _selectedIndexes.clear();
            _resultTabIndex = 0;
            _physicalTagDraftByAppId.clear();
            _physicalTagControllerByAppId.clear();
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _stateSubscription.close();
    _scanController.dispose();
    _scanFocusNode.dispose();
    for (final controller in _physicalTagControllerByAppId.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _search({String? overrideCode}) async {
    final value = overrideCode ?? _scanController.text;
    final code = value.trim();
    final controller = ref.read(visitorCheckControllerProvider.notifier);
    controller.updateSearchInput(value);
    final ok = await controller.search(isCheckIn: widget.isCheckIn);
    if (ok && code.isNotEmpty) {
      _lastLookupCode = code;
    }
  }

  Future<void> _openScannerAndSearch() async {
    final scannerResult =
        await (widget.scanLauncher?.call(context) ??
            Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (_) => const MobileScannerPage(
                  title: 'Scan QR Code',
                  description: 'Align QR code inside the frame to scan.',
                ),
              ),
            ));

    final scanned = scannerResult?.trim() ?? '';
    if (scanned.isEmpty || !mounted) {
      return;
    }
    await _search(overrideCode: scanned);
  }

  Future<void> _scanPhysicalTagFor(VisitorLookupItemEntity visitor) async {
    final result =
        await (widget.physicalTagScanLauncher?.call(context) ??
            Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (_) => const MobileScannerPage(
                  title: 'Scan Physical Tag',
                  description:
                      'Align QR code inside the frame to scan physical tag.',
                ),
              ),
            ));
    final scanned = result?.trim() ?? '';
    if (scanned.isEmpty || !mounted) {
      return;
    }
    final appId = visitor.icPassport.trim();
    if (appId.isEmpty) {
      return;
    }
    _setPhysicalTagFor(visitor, scanned);
    final controller = _physicalTagControllerByAppId[appId];
    if (controller != null && controller.text != scanned) {
      controller.value = TextEditingValue(
        text: scanned,
        selection: TextSelection.collapsed(offset: scanned.length),
      );
    }
    setState(() {});
  }

  String _physicalTagFor(VisitorLookupItemEntity visitor) {
    final appId = visitor.icPassport.trim();
    if (appId.isEmpty) {
      return visitor.physicalTag.trim();
    }
    if (!_physicalTagDraftByAppId.containsKey(appId)) {
      _physicalTagDraftByAppId[appId] = visitor.physicalTag.trim();
    }
    return _physicalTagDraftByAppId[appId] ?? '';
  }

  void _setPhysicalTagFor(VisitorLookupItemEntity visitor, String value) {
    final appId = visitor.icPassport.trim();
    if (appId.isEmpty) {
      return;
    }
    _physicalTagDraftByAppId[appId] = value;
  }

  TextEditingController _physicalTagControllerFor(
    VisitorLookupItemEntity visitor,
  ) {
    final appId = visitor.icPassport.trim();
    final existing = _physicalTagControllerByAppId[appId];
    final value = _physicalTagFor(visitor);
    if (existing != null) {
      if (existing.text != value) {
        existing.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      return existing;
    }
    final controller = TextEditingController(text: value);
    _physicalTagControllerByAppId[appId] = controller;
    return controller;
  }

  void _clear() {
    _lastLookupCode = '';
    ref.read(visitorCheckControllerProvider.notifier).clearAll();
  }

  Future<void> _confirmSubmit({
    required VisitorCheckState state,
    required List<VisitorLookupItemEntity> visitors,
    required Set<int> eligibleIndexes,
  }) async {
    final lookup = state.lookup;
    if (lookup == null) {
      showAppSnackBar(context, 'Please search visitor data first.');
      return;
    }

    final selectedEligible = _selectedIndexes
        .where(eligibleIndexes.contains)
        .toList(growable: false);
    if (selectedEligible.isEmpty) {
      showAppSnackBar(context, 'Select at least one eligible visitor.');
      return;
    }

    final session = await ref.read(authLocalDataSourceProvider).getSession();
    final userId = session?.username.trim() ?? '';
    final site = session?.defaultSite.trim() ?? '';
    final gate = session?.defaultGate.trim() ?? '';
    final actionLabel = widget.isCheckIn ? 'check-in' : 'check-out';
    final actionPast = widget.isCheckIn ? 'checked in' : 'checked out';
    if (userId.isEmpty || site.isEmpty || gate.isEmpty) {
      if (mounted) {
        showAppSnackBar(context, 'Please login again to submit $actionLabel.');
      }
      return;
    }

    final selectedVisitors = <VisitorCheckInSubmissionItemEntity>[];
    for (final index in selectedEligible) {
      final visitor = visitors[index];
      final appId = visitor.icPassport.trim();
      if (appId.isEmpty) {
        if (mounted) {
          showAppSnackBar(
            context,
            'Selected visitor has empty IC/Passport and cannot be $actionPast.',
          );
        }
        return;
      }
      selectedVisitors.add(
        VisitorCheckInSubmissionItemEntity(
          appId: appId,
          physicalTag:
              (widget.isCheckIn
                      ? (_physicalTagDraftByAppId[appId] ?? visitor.physicalTag)
                      : visitor.physicalTag)
                  .trim(),
        ),
      );
    }

    final submission = VisitorCheckInSubmissionEntity(
      userId: userId,
      entity: lookup.entity.trim(),
      site: site,
      gate: gate,
      invitationId: lookup.invitationId.trim(),
      visitors: selectedVisitors,
    );

    final controller = ref.read(visitorCheckControllerProvider.notifier);
    final result = await (widget.isCheckIn
        ? controller.submitCheckIn(submission: submission)
        : controller.submitCheckOut(submission: submission));

    if (!mounted) {
      return;
    }

    final defaultMessage = widget.isCheckIn
        ? 'Checked-in successfully.'
        : 'Checked-out successfully.';
    final message = result.message.trim().isEmpty
        ? defaultMessage
        : result.message;
    showAppSnackBar(context, message);

    if (!result.status) {
      return;
    }

    setState(() {
      _selectedIndexes.clear();
    });

    if (_lastLookupCode.isNotEmpty) {
      await _search(overrideCode: _lastLookupCode);
    }
  }

  String _displayOrDash(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  String _visitorTypeDisplay(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '-';
    }
    final parts = text.split('_');
    if (parts.length == 2 && parts.last.trim().isNotEmpty) {
      return parts.last.trim();
    }
    return text;
  }

  String _visitStatus(VisitorLookupItemEntity visitor) {
    final hasCheckOut = visitor.checkOutTime.trim().isNotEmpty;
    if (hasCheckOut) {
      return 'OUT';
    }
    final hasCheckIn = visitor.checkInTime.trim().isNotEmpty;
    if (hasCheckIn) {
      return 'IN';
    }
    return '-';
  }

  bool _isEligibleForCurrentAction(VisitorLookupItemEntity visitor) {
    if (widget.isCheckIn) {
      return visitor.checkInTime.trim().isEmpty;
    }
    return visitor.checkOutTime.trim().isEmpty;
  }

  Set<int> _eligibleIndexes(List<VisitorLookupItemEntity> visitors) {
    final result = <int>{};
    for (var i = 0; i < visitors.length; i++) {
      if (_isEligibleForCurrentAction(visitors[i])) {
        result.add(i);
      }
    }
    return result;
  }

  String _formatDateTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return text;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();

    final hour24 = parsed.hour;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final meridiem = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = ((hour24 + 11) % 12 + 1).toString().padLeft(2, '0');

    return '$day/$month/$year $hour12:$minute $meridiem';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitorCheckControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final lookup = state.lookup;
    final visitors = lookup?.visitors ?? const <VisitorLookupItemEntity>[];
    final hasResult = lookup != null;
    final eligibleIndexes = _eligibleIndexes(visitors);
    final selectedEligibleCount = _selectedIndexes
        .where(eligibleIndexes.contains)
        .length;
    final hasEligibleVisitors = eligibleIndexes.isNotEmpty;
    final allEligibleSelected =
        hasEligibleVisitors && selectedEligibleCount == eligibleIndexes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCheckIn ? 'Visitor Check-In' : 'Visitor Check-Out',
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Scan',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _FlatInputField(
                        controller: _scanController,
                        label: 'Scan QR Code',
                        hintText: 'Please input',
                        trailingIcon: Icons.qr_code_scanner,
                        onChanged: ref
                            .read(visitorCheckControllerProvider.notifier)
                            .updateSearchInput,
                        onTrailingTap: state.isLoading || state.isSubmitting
                            ? null
                            : _openScannerAndSearch,
                        focusNode: _scanFocusNode,
                      ),
                      FormRowDivider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppFilledButton(
                              onPressed: state.isLoading || state.isSubmitting
                                  ? null
                                  : _search,
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
                          const SizedBox(width: 10),
                          AppOutlinedButton(
                            onPressed: state.isLoading || state.isSubmitting
                                ? null
                                : _clear,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      if (state.errorMessage != null &&
                          state.errorMessage!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (hasResult) const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (hasResult)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySegmentHeaderDelegate(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _ResultTabBar(
                    selectedIndex: _resultTabIndex,
                    visitorCount: visitors.length,
                    onChanged: (index) =>
                        setState(() => _resultTabIndex = index),
                  ),
                ),
                height: 56,
              ),
            ),
          if (hasResult) const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (hasResult && _resultTabIndex == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Visitor Summary',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InfoRow(
                          label: 'Invitation ID',
                          value: _displayOrDash(lookup.invitationId),
                        ),
                        InfoRow(
                          label: 'Department',
                          value: _displayOrDash(
                            lookup.departmentDesc.trim().isNotEmpty
                                ? lookup.departmentDesc
                                : lookup.department,
                          ),
                        ),
                        InfoRow(
                          label: 'Purpose',
                          value: _displayOrDash(lookup.purpose),
                        ),
                        InfoRow(
                          label: 'Site',
                          value: _displayOrDash(
                            lookup.siteDesc.trim().isNotEmpty
                                ? lookup.siteDesc
                                : lookup.site,
                          ),
                        ),
                        InfoRow(
                          label: 'Company',
                          value: _displayOrDash(lookup.company),
                        ),
                        InfoRow(
                          label: 'Contact',
                          value: _displayOrDash(lookup.contactNumber),
                        ),
                        const FormRowDivider(height: 12),
                        InfoRow(
                          label: 'Visitor Type',
                          value: _visitorTypeDisplay(lookup.visitorType),
                        ),
                        InfoRow(
                          label: 'Invite By',
                          value: _displayOrDash(lookup.inviteBy),
                        ),
                        InfoRow(
                          label: 'Work Level',
                          value: _displayOrDash(lookup.workLevel),
                        ),
                        InfoRow(
                          label: 'Vehicle Plate',
                          value: _displayOrDash(lookup.vehiclePlateNumber),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (hasResult && _resultTabIndex == 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckboxListTile(
                      value: allEligibleSelected,
                      onChanged: hasEligibleVisitors
                          ? (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedIndexes
                                    ..clear()
                                    ..addAll(eligibleIndexes);
                                } else {
                                  _selectedIndexes.clear();
                                }
                              });
                            }
                          : null,
                      title: Text(
                        'Select all ($selectedEligibleCount/${eligibleIndexes.length})',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          if (hasResult && _resultTabIndex == 1)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final visitor = visitors[i];
                  final isEligible = _isEligibleForCurrentAction(visitor);
                  final isPhysicalTagEditable =
                      widget.isCheckIn && visitor.checkInTime.trim().isEmpty;
                  final isPhysicalTagEnabled =
                      isPhysicalTagEditable && _selectedIndexes.contains(i);
                  return _VisitorCard(
                    invitationId: lookup.invitationId,
                    visitor: visitor,
                    selected: _selectedIndexes.contains(i),
                    isEligible: isEligible,
                    isCheckInMode: widget.isCheckIn,
                    isPhysicalTagEditable: isPhysicalTagEditable,
                    checkStatus: _visitStatus(visitor),
                    checkInDate: _formatDateTime(visitor.checkInTime),
                    checkOutDate: _formatDateTime(visitor.checkOutTime),
                    physicalTagController: isPhysicalTagEditable
                        ? _physicalTagControllerFor(visitor)
                        : null,
                    onPhysicalTagChanged: isPhysicalTagEnabled
                        ? (value) => _setPhysicalTagFor(visitor, value)
                        : null,
                    onPhysicalTagScanTap: isPhysicalTagEnabled
                        ? () => _scanPhysicalTagFor(visitor)
                        : null,
                    onSelected: isEligible
                        ? (checked) {
                            setState(() {
                              if (checked == true) {
                                if (_isEligibleForCurrentAction(visitor)) {
                                  _selectedIndexes.add(i);
                                }
                              } else {
                                _selectedIndexes.remove(i);
                              }
                            });
                          }
                        : null,
                  );
                }, childCount: visitors.length),
              ),
            ),
          if (hasResult)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Take Photo',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppOutlinedButtonIcon(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PhotoThumb(hasPhoto: true),
                            _PhotoThumb(hasPhoto: false),
                            _PhotoThumb(hasPhoto: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: AppFilledButton(
          onPressed:
              !state.isSubmitting &&
                  !state.isLoading &&
                  selectedEligibleCount > 0
              ? () => _confirmSubmit(
                  state: state,
                  visitors: visitors,
                  eligibleIndexes: eligibleIndexes,
                )
              : null,
          child: state.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.isCheckIn ? 'Confirm Check-In' : 'Confirm Check-Out',
                ),
        ),
      ),
    );
  }
}

class _VisitorCard extends StatelessWidget {
  const _VisitorCard({
    required this.invitationId,
    required this.visitor,
    required this.selected,
    required this.isEligible,
    required this.isCheckInMode,
    required this.isPhysicalTagEditable,
    required this.checkStatus,
    required this.checkInDate,
    required this.checkOutDate,
    required this.physicalTagController,
    required this.onPhysicalTagChanged,
    required this.onPhysicalTagScanTap,
    required this.onSelected,
  });

  final String invitationId;
  final VisitorLookupItemEntity visitor;
  final bool selected;
  final bool isEligible;
  final bool isCheckInMode;
  final bool isPhysicalTagEditable;
  final String checkStatus;
  final String checkInDate;
  final String checkOutDate;
  final TextEditingController? physicalTagController;
  final ValueChanged<String>? onPhysicalTagChanged;
  final VoidCallback? onPhysicalTagScanTap;
  final ValueChanged<bool?>? onSelected;

  String _displayOrDash(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(value: selected, onChanged: onSelected),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayOrDash(visitor.name),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _displayOrDash(visitor.icPassport),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VisitorPhotoSlot(
                      invitationId: invitationId,
                      appId: visitor.icPassport,
                    ),
                    const SizedBox(width: 8),
                    _StatusTag(status: checkStatus),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            InfoRow(label: 'Check In Date', value: checkInDate),
            InfoRow(label: 'Check Out Date', value: checkOutDate),
            // const InfoRow(label: 'Gate In', value: '-'),
            // const InfoRow(label: 'Gate Out', value: '-'),
            // const InfoRow(label: 'Check In By', value: '-'),
            // const InfoRow(label: 'Check Out By', value: '-'),
            if (isCheckInMode && isPhysicalTagEditable)
              _PhysicalTagInputRow(
                appId: visitor.icPassport.trim(),
                controller: physicalTagController!,
                enabled: onPhysicalTagChanged != null,
                onChanged: onPhysicalTagChanged,
                onScanTap: onPhysicalTagScanTap,
              )
            else
              InfoRow(
                label: 'Physical Tag',
                value: _displayOrDash(visitor.physicalTag),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: AppOutlinedButtonIcon(
                onPressed: () {},
                icon: const Icon(Icons.history),
                label: const Text('History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhysicalTagInputRow extends StatelessWidget {
  const _PhysicalTagInputRow({
    required this.appId,
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.onScanTap,
  });

  final String appId;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Physical Tag',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: TextFormField(
              key: Key('physical-tag-input-$appId'),
              enabled: enabled,
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Optional',
                isDense: true,
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: Key('physical-tag-scan-$appId'),
            tooltip: 'Scan physical tag',
            onPressed: onScanTap,
            icon: const Icon(Icons.qr_code_scanner),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toUpperCase();
    final colorScheme = Theme.of(context).colorScheme;
    final (text, bg, fg) = switch (normalized) {
      'IN' => ('IN', colorScheme.primary, colorScheme.onPrimary),
      'OUT' => ('OUT', colorScheme.error, colorScheme.onError),
      _ => ('', Colors.transparent, Colors.transparent),
    };
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ResultTabBar extends StatelessWidget {
  const _ResultTabBar({
    required this.selectedIndex,
    required this.visitorCount,
    required this.onChanged,
  });

  final int selectedIndex;
  final int visitorCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _ResultTabChip(
                label: 'Summary',
                selected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ResultTabChip(
                label: 'Visitor List ($visitorCount)',
                selected: selectedIndex == 1,
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySegmentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickySegmentHeaderDelegate({
    required this.child,
    required this.backgroundColor,
    required this.height,
  });

  final Widget child;
  final Color backgroundColor;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: ColoredBox(color: backgroundColor, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySegmentHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.height != height;
  }
}

class _ResultTabChip extends StatelessWidget {
  const _ResultTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoMock extends StatelessWidget {
  const _PhotoMock({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 72,
        width: 72,
        color: hasPhoto ? colorScheme.primaryContainer : Colors.grey.shade300,
        child: Icon(
          hasPhoto ? Icons.check_circle : Icons.person,
          size: 30,
          color: hasPhoto ? colorScheme.onPrimaryContainer : Colors.black54,
        ),
      ),
    );
  }
}

class _VisitorPhotoSlot extends ConsumerWidget {
  const _VisitorPhotoSlot({required this.invitationId, required this.appId});

  final String invitationId;
  final String appId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = VisitorPhotoKey(invitationId: invitationId, appId: appId);
    return RemotePhotoSlot(
      asyncBytes: ref.watch(visitorApplicantImageProvider(key)),
      thumbnailKey: const Key('visitor-photo-thumbnail'),
      fullscreenKey: const Key('visitor-photo-fullscreen'),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _PhotoMock(hasPhoto: hasPhoto),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, size: 12),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minHeight: 20, minWidth: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlatInputField extends StatelessWidget {
  const _FlatInputField({
    required this.label,
    required this.hintText,
    this.controller,
    this.trailingIcon,
    this.onTrailingTap,
    this.onChanged,
    this.focusNode,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onTrailingTap,
                icon: Icon(trailingIcon),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        const _FieldRowDivider(),
      ],
    );
  }
}

class _FieldRowDivider extends StatelessWidget {
  const _FieldRowDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 0.6,
      color: colorScheme.outline.withValues(alpha: 0.25),
    );
  }
}
