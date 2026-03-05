import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vms_bernas/presentation/widgets/labeled_form_rows.dart';

import '../../domain/entities/visitor_check_in_submission_entity.dart';
import '../../domain/entities/visitor_check_in_submission_item_entity.dart';
import '../../domain/entities/visitor_gallery_item_entity.dart';
import '../../domain/entities/visitor_lookup_entity.dart';
import '../../domain/entities/visitor_lookup_item_entity.dart';
import '../../domain/entities/visitor_save_photo_submission_entity.dart';
import 'mobile_scanner_page.dart';
import '../state/auth_session_providers.dart';
import '../state/device_service_providers.dart';
import '../state/visitor_check_in_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/info_row.dart';
import '../widgets/remote_photo_slot.dart';
import '../widgets/app_snackbar.dart';
import '../services/camera_capture_service.dart';

class VisitorCheckInPage extends ConsumerStatefulWidget {
  const VisitorCheckInPage({
    super.key,
    required this.isCheckIn,
    this.scanLauncher,
    this.physicalTagScanLauncher,
    this.cameraLauncher,
  });

  final bool isCheckIn;
  final Future<String?> Function(BuildContext context)? scanLauncher;
  final Future<String?> Function(BuildContext context)? physicalTagScanLauncher;
  final Future<XFile?> Function(BuildContext context)? cameraLauncher;

  @override
  ConsumerState<VisitorCheckInPage> createState() => _VisitorCheckInPageState();
}

class _VisitorCheckInPageState extends ConsumerState<VisitorCheckInPage> {
  final _scanController = TextEditingController();
  final _scanFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final _gallerySectionKey = GlobalKey();
  final Set<int> _selectedIndexes = <int>{};
  final Map<String, String> _physicalTagDraftByAppId = <String, String>{};
  final Map<String, String> _physicalTagErrorByAppId = <String, String>{};
  final Map<String, TextEditingController> _physicalTagControllerByAppId =
      <String, TextEditingController>{};
  final Map<String, FocusNode> _physicalTagFocusNodeByAppId =
      <String, FocusNode>{};
  final Map<String, GlobalKey> _visitorCardKeyByAppId = <String, GlobalKey>{};
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
          for (final focusNode in _physicalTagFocusNodeByAppId.values) {
            focusNode.dispose();
          }
          setState(() {
            _selectedIndexes.clear();
            _resultTabIndex = 0;
            _physicalTagDraftByAppId.clear();
            _physicalTagErrorByAppId.clear();
            _physicalTagControllerByAppId.clear();
            _physicalTagFocusNodeByAppId.clear();
            _visitorCardKeyByAppId.clear();
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
    _scrollController.dispose();
    for (final controller in _physicalTagControllerByAppId.values) {
      controller.dispose();
    }
    for (final focusNode in _physicalTagFocusNodeByAppId.values) {
      focusNode.dispose();
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
    setState(() {
      _physicalTagErrorByAppId.remove(appId);
    });
  }

  Future<void> _captureFromCamera() async {
    final state = ref.read(visitorCheckControllerProvider);
    final lookup = state.lookup;
    if (lookup == null || lookup.invitationId.trim().isEmpty) {
      showAppSnackBar(context, 'Please search visitor data first.');
      return;
    }

    final session = await ref.read(authLocalDataSourceProvider).getSession();
    final uploadedBy = session?.username.trim() ?? '';
    final entity = session?.entity.trim() ?? '';
    final site = session?.defaultSite.trim() ?? '';
    if (uploadedBy.isEmpty || entity.isEmpty || site.isEmpty) {
      if (mounted) {
        showAppSnackBar(context, 'Please login again to upload photo.');
      }
      return;
    }
    if (!mounted) {
      return;
    }

    try {
      final capturedFile =
          await (widget.cameraLauncher?.call(context) ??
              ref.read(cameraCaptureServiceProvider).capturePhoto());
      if (!mounted || capturedFile == null) {
        return;
      }

      final bytes = await capturedFile.readAsBytes();
      if (!mounted || bytes.isEmpty) {
        return;
      }

      final uploaded = await _showUploadPhotoSheet(
        imageBytes: bytes,
        lookup: lookup,
        uploadedBy: uploadedBy,
        entity: entity,
        site: site,
      );
      if (!mounted || uploaded == null) {
        return;
      }

      showAppSnackBar(
        context,
        uploaded.message.isEmpty
            ? 'Photo saved successfully.'
            : uploaded.message,
      );
      if (uploaded.photoId != null && uploaded.photoId! > 0) {
        ref
            .read(visitorGalleryLocalItemsProvider.notifier)
            .append(
              invitationId: lookup.invitationId,
              item: VisitorGalleryItemEntity(
                photoId: uploaded.photoId!,
                photoDesc: uploaded.photoDescription,
                url: '/visitor/photo/${uploaded.photoId}',
              ),
            );
        seedVisitorGalleryPhotoCache(
          ref,
          photoId: uploaded.photoId!,
          bytes: bytes,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = switch (error) {
        CameraCaptureException e => e.message,
        _ => 'Unable to open camera. Please try again.',
      };
      showAppSnackBar(context, message);
    }
  }

  Future<_UploadedPhotoResult?> _showUploadPhotoSheet({
    required Uint8List imageBytes,
    required VisitorLookupEntity lookup,
    required String uploadedBy,
    required String entity,
    required String site,
  }) {
    return showModalBottomSheet<_UploadedPhotoResult>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final descriptionController = TextEditingController();
        String? errorText;
        bool isUploading = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> upload() async {
              final submission = VisitorSavePhotoSubmissionEntity(
                imageBase64: base64Encode(imageBytes),
                photoDescription: descriptionController.text.trim(),
                invitationId: lookup.invitationId.trim(),
                entity: entity,
                site: site,
                uploadedBy: uploadedBy,
              );

              setSheetState(() {
                isUploading = true;
                errorText = null;
              });

              final result = await ref
                  .read(visitorCheckControllerProvider.notifier)
                  .savePhoto(submission: submission);

              if (!mounted || !context.mounted) {
                return;
              }

              if (!result.success) {
                setSheetState(() {
                  isUploading = false;
                  errorText = result.message.isEmpty
                      ? 'Failed to upload visitor photo.'
                      : result.message;
                });
                return;
              }

              Navigator.of(sheetContext).pop(
                _UploadedPhotoResult(
                  message: result.message,
                  photoId: result.photoId,
                  photoDescription: descriptionController.text.trim(),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload Photo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      enabled: !isUploading,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Photo Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlinedButton(
                            onPressed: isUploading
                                ? null
                                : () => Navigator.of(sheetContext).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppFilledButton(
                            onPressed: isUploading ? null : upload,
                            child: isUploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Upload'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  void _onPhysicalTagChanged(VisitorLookupItemEntity visitor, String value) {
    _setPhysicalTagFor(visitor, value);
    final appId = visitor.icPassport.trim();
    if (appId.isEmpty) {
      return;
    }
    if (value.trim().isNotEmpty &&
        _physicalTagErrorByAppId.containsKey(appId)) {
      setState(() {
        _physicalTagErrorByAppId.remove(appId);
      });
    }
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

  FocusNode _physicalTagFocusNodeFor(VisitorLookupItemEntity visitor) {
    final appId = visitor.icPassport.trim();
    final existing = _physicalTagFocusNodeByAppId[appId];
    if (existing != null) {
      return existing;
    }
    final focusNode = FocusNode();
    _physicalTagFocusNodeByAppId[appId] = focusNode;
    return focusNode;
  }

  GlobalKey _visitorCardKeyFor(VisitorLookupItemEntity visitor, int index) {
    final appId = visitor.icPassport.trim();
    final keyId = appId.isEmpty ? '__visitor_$index' : appId;
    final existing = _visitorCardKeyByAppId[keyId];
    if (existing != null) {
      return existing;
    }
    final key = GlobalKey(debugLabel: 'visitor-card-$keyId');
    _visitorCardKeyByAppId[keyId] = key;
    return key;
  }

  void _focusFirstMissingPhysicalTag({
    required VisitorLookupItemEntity visitor,
    required int index,
  }) {
    if (_resultTabIndex != 1) {
      setState(() => _resultTabIndex = 1);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final appId = visitor.icPassport.trim();
      final targetContext = _visitorCardKeyByAppId[appId]?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          alignment: 0.1,
        );
        _physicalTagFocusNodeByAppId[appId]?.requestFocus();
        return;
      }
      if (!_scrollController.hasClients) {
        return;
      }
      final estimatedOffset = (index * 220.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController
          .animateTo(
            estimatedOffset,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
          )
          .then((_) {
            if (!mounted) {
              return;
            }
            _physicalTagFocusNodeByAppId[appId]?.requestFocus();
          });
    });
  }

  void _clear() {
    _lastLookupCode = '';
    ref.read(visitorCheckControllerProvider.notifier).clearAll();
  }

  Future<void> _goToGallerySection() async {
    if (_resultTabIndex != 0) {
      setState(() => _resultTabIndex = 0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final targetContext = _gallerySectionKey.currentContext;
      if (targetContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        alignment: 0.1,
      );
    });
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

    if (widget.isCheckIn) {
      final missingIndexes = <int>[];
      setState(() {
        for (final index in selectedEligible) {
          final visitor = visitors[index];
          final appId = visitor.icPassport.trim();
          if (appId.isEmpty) {
            continue;
          }
          final physicalTag =
              (_physicalTagDraftByAppId[appId] ?? visitor.physicalTag).trim();
          if (physicalTag.isEmpty) {
            _physicalTagErrorByAppId[appId] = 'Required';
            missingIndexes.add(index);
          } else {
            _physicalTagErrorByAppId.remove(appId);
          }
        }
      });
      if (missingIndexes.isNotEmpty) {
        showAppSnackBar(
          context,
          'Physical Tag is required for selected visitors before check-in.',
        );
        final firstMissingIndex = missingIndexes.first;
        _focusFirstMissingPhysicalTag(
          visitor: visitors[firstMissingIndex],
          index: firstMissingIndex,
        );
        return;
      }
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
      final physicalTag =
          (widget.isCheckIn
                  ? (_physicalTagDraftByAppId[appId] ?? visitor.physicalTag)
                  : visitor.physicalTag)
              .trim();
      selectedVisitors.add(
        VisitorCheckInSubmissionItemEntity(
          appId: appId,
          physicalTag: physicalTag,
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
        controller: _scrollController,
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
                      LabeledTextInputRow(
                        controller: _scanController,
                        label: 'Scan QR Code',
                        hintText: 'Please input',
                        onChanged: ref
                            .read(visitorCheckControllerProvider.notifier)
                            .updateSearchInput,
                        focusNode: _scanFocusNode,
                        suffixIcon: CompactSuffixTapIcon(
                          key: const Key('visitor-scan-button'),
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
                                final previouslySelected = _selectedIndexes
                                    .toList(growable: false);
                                if (checked == true) {
                                  _selectedIndexes
                                    ..clear()
                                    ..addAll(eligibleIndexes);
                                } else {
                                  _selectedIndexes.clear();
                                }
                                if (checked != true) {
                                  for (final selectedIndex
                                      in previouslySelected) {
                                    final appId = visitors[selectedIndex]
                                        .icPassport
                                        .trim();
                                    if (appId.isNotEmpty) {
                                      _physicalTagErrorByAppId.remove(appId);
                                    }
                                  }
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
                    key: _visitorCardKeyFor(visitor, i),
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
                    physicalTagFocusNode: isPhysicalTagEditable
                        ? _physicalTagFocusNodeFor(visitor)
                        : null,
                    physicalTagErrorText:
                        _physicalTagErrorByAppId[visitor.icPassport.trim()],
                    onPhysicalTagChanged: isPhysicalTagEnabled
                        ? (value) => _onPhysicalTagChanged(visitor, value)
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
                                _physicalTagErrorByAppId.remove(
                                  visitor.icPassport.trim(),
                                );
                              }
                            });
                          }
                        : null,
                    onHistoryTap: _goToGallerySection,
                  );
                }, childCount: visitors.length),
              ),
            ),
          if (hasResult && _resultTabIndex == 0)
            SliverToBoxAdapter(
              key: _gallerySectionKey,
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
                          onPressed:
                              state.isLoading ||
                                  state.isSubmitting ||
                                  state.isUploadingPhoto
                              ? null
                              : _captureFromCamera,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(height: 12),
                        _VisitorGallerySection(
                          invitationId: lookup.invitationId,
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
                  !state.isUploadingPhoto &&
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
    super.key,
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
    required this.physicalTagFocusNode,
    required this.physicalTagErrorText,
    required this.onPhysicalTagChanged,
    required this.onPhysicalTagScanTap,
    required this.onSelected,
    required this.onHistoryTap,
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
  final FocusNode? physicalTagFocusNode;
  final String? physicalTagErrorText;
  final ValueChanged<String>? onPhysicalTagChanged;
  final VoidCallback? onPhysicalTagScanTap;
  final ValueChanged<bool?>? onSelected;
  final Future<void> Function() onHistoryTap;

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
                focusNode: physicalTagFocusNode!,
                enabled: onPhysicalTagChanged != null,
                onChanged: onPhysicalTagChanged,
                onScanTap: onPhysicalTagScanTap,
                errorText: physicalTagErrorText,
              )
            else
              InfoRow(
                label: 'Physical Tag',
                value: _displayOrDash(visitor.physicalTag),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: AppOutlinedButtonIcon(
                key: Key('visitor-history-${visitor.icPassport.trim()}'),
                onPressed: onHistoryTap,
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
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
    required this.onScanTap,
    required this.errorText,
  });

  final String appId;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScanTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return LabeledTextInputRow(
      label: 'Physical Tag',
      hintText: 'Required',
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      enabled: enabled,
      errorText: errorText,
      inputFieldKey: Key('physical-tag-input-$appId'),
      suffixIcon: CompactSuffixTapIcon(
        key: Key('physical-tag-scan-$appId'),
        icon: Icons.qr_code_scanner,
        enabled: enabled,
        onTap: onScanTap,
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

class _VisitorGallerySection extends ConsumerWidget {
  const _VisitorGallerySection({required this.invitationId});

  final String invitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(visitorGalleryListProvider(invitationId));
    final localItems = ref.watch(
      visitorGalleryLocalItemsProvider.select(
        (map) => map[invitationId.trim()] ?? const <VisitorGalleryItemEntity>[],
      ),
    );
    final deletedPhotoIds = ref.watch(
      visitorGalleryDeletedPhotoIdsProvider.select(
        (map) => map[invitationId.trim()] ?? const <int>{},
      ),
    );
    final isDeletingPhoto = ref.watch(
      visitorCheckControllerProvider.select((state) => state.isDeletingPhoto),
    );
    final deletingPhotoId = ref.watch(
      visitorCheckControllerProvider.select((state) => state.deletingPhotoId),
    );
    final colorScheme = Theme.of(context).colorScheme;
    return galleryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _toErrorMessage(error),
            style: TextStyle(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: AppOutlinedButton(
              onPressed: () =>
                  ref.invalidate(visitorGalleryListProvider(invitationId)),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
      data: (items) {
        final mergedItems = _mergeGalleryItems(
          remoteItems: items,
          localItems: localItems,
          deletedPhotoIds: deletedPhotoIds,
        );
        if (mergedItems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('No uploaded photos found.'),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mergedItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) => _GalleryThumb(
            invitationId: invitationId,
            item: mergedItems[index],
            isDeleting:
                isDeletingPhoto &&
                deletingPhotoId == mergedItems[index].photoId,
          ),
        );
      },
    );
  }

  List<VisitorGalleryItemEntity> _mergeGalleryItems({
    required List<VisitorGalleryItemEntity> remoteItems,
    required List<VisitorGalleryItemEntity> localItems,
    required Set<int> deletedPhotoIds,
  }) {
    final seen = <int>{};
    final merged = <VisitorGalleryItemEntity>[];
    for (final item in [...localItems, ...remoteItems]) {
      if (deletedPhotoIds.contains(item.photoId)) {
        continue;
      }
      if (seen.add(item.photoId)) {
        merged.add(item);
      }
    }
    // Keep newer photos at the back for consistent gallery ordering.
    merged.sort((a, b) => a.photoId.compareTo(b.photoId));
    return merged;
  }

  String _toErrorMessage(Object error) {
    final text = error.toString().trim();
    if (text.startsWith('Exception:')) {
      return text.replaceFirst('Exception:', '').trim();
    }
    return text.isEmpty ? 'Failed to load gallery photos.' : text;
  }
}

class _UploadedPhotoResult {
  const _UploadedPhotoResult({
    required this.message,
    required this.photoId,
    required this.photoDescription,
  });

  final String message;
  final int? photoId;
  final String photoDescription;
}

class _GalleryThumb extends ConsumerWidget {
  const _GalleryThumb({
    required this.invitationId,
    required this.item,
    required this.isDeleting,
  });

  final String invitationId;
  final VisitorGalleryItemEntity item;
  final bool isDeleting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(
      visitorGalleryPhotoProvider(
        VisitorGalleryPhotoKey(photoId: item.photoId),
      ),
    );
    Future<void> deletePhoto() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete photo?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) {
        return;
      }

      final result = await ref
          .read(visitorCheckControllerProvider.notifier)
          .deletePhoto(photoId: item.photoId);
      if (!context.mounted) {
        return;
      }
      if (!result.success) {
        showAppSnackBar(
          context,
          result.message.isEmpty
              ? 'Failed to delete gallery photo. Please try again.'
              : result.message,
        );
        return;
      }

      ref
          .read(visitorGalleryLocalItemsProvider.notifier)
          .remove(invitationId: invitationId, photoId: item.photoId);
      ref
          .read(visitorGalleryDeletedPhotoIdsProvider.notifier)
          .markDeleted(invitationId: invitationId, photoId: item.photoId);
      removeVisitorGalleryPhotoCache(ref, photoId: item.photoId);
      showAppSnackBar(
        context,
        result.message.isEmpty ? 'Photo deleted successfully.' : result.message,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RemotePhotoSlot(asyncBytes: photoAsync, size: 72),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            key: Key('gallery-delete-${item.photoId}'),
            onTap: isDeleting ? null : deletePhoto,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDeleting ? Colors.black38 : Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  isDeleting ? Icons.hourglass_top : Icons.delete_outline,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
