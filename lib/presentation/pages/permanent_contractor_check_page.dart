import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/date_time_formats.dart';
import '../../core/error_messages.dart';
import '../../domain/entities/permanent_contractor_gallery_item_entity.dart';
import '../../domain/entities/permanent_contractor_save_photo_submission_entity.dart';
import '../services/camera_capture_service.dart';
import '../services/mobile_scanner_launcher.dart';
import '../state/auth_session_providers.dart';
import '../state/device_service_providers.dart';
import '../state/permanent_contractor_check_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/check_type_segmented_control.dart';
import '../widgets/gallery_photo_grid.dart';
import '../widgets/gallery_photo_tile.dart';
import '../widgets/info_row.dart';
import '../widgets/labeled_form_rows.dart';
import '../widgets/photo_upload_bottom_sheet.dart';
import '../widgets/remote_photo_slot.dart';

class PermanentContractorCheckPage extends ConsumerStatefulWidget {
  const PermanentContractorCheckPage({
    super.key,
    required this.initialCheckType,
    this.scanLauncher,
    this.cameraLauncher,
  });

  final PermanentContractorCheckType initialCheckType;
  final Future<String?> Function(BuildContext context)? scanLauncher;
  final Future<XFile?> Function(BuildContext context)? cameraLauncher;

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
    if (result.status) {
      ref
          .read(permanentContractorCheckControllerProvider.notifier)
          .resetAfterSuccessfulSubmit();
    }
  }

  Future<void> _captureFromCamera() async {
    final state = ref.read(permanentContractorCheckControllerProvider);
    final info = state.info;
    final guid = state.photoSessionGuid.trim();
    if (info == null || info.contractorId.trim().isEmpty || guid.isEmpty) {
      showAppSnackBar(context, 'Please search contractor info before upload.');
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

      final uploaded = await showPhotoUploadBottomSheet(
        context: context,
        imageBytes: bytes,
        onUpload: (photoDescription) async {
          final submission = PermanentContractorSavePhotoSubmissionEntity(
            imageBase64: base64Encode(bytes),
            photoDescription: photoDescription,
            guid: guid,
            entity: entity,
            site: site,
            uploadedBy: uploadedBy,
          );
          final result = await ref
              .read(permanentContractorCheckControllerProvider.notifier)
              .savePhoto(submission: submission);
          return PhotoUploadRequestResult(
            success: result.success,
            message: result.message,
            photoId: result.photoId,
          );
        },
        failureFallback: 'Failed to upload permanent contractor photo.',
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
            .read(permanentContractorGalleryLocalItemsProvider.notifier)
            .append(
              guid: guid,
              item: PermanentContractorGalleryItemEntity(
                photoId: uploaded.photoId!,
                photoDesc: uploaded.photoDescription,
                url: '/Contractor/photo/${uploaded.photoId}',
              ),
            );
        seedPermanentContractorGalleryPhotoCache(
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
          if (state.info != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppOutlinedButtonIcon(
                      key: const Key(
                        'permanent-contractor-gallery-camera-button',
                      ),
                      onPressed:
                          state.isUploadingPhoto ||
                              state.isLoading ||
                              state.isSubmitting ||
                              state.photoSessionGuid.trim().isEmpty
                          ? null
                          : _captureFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                    const SizedBox(height: 12),
                    _PermanentContractorGallerySection(
                      guid: state.photoSessionGuid.trim(),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _PermanentContractorGallerySection extends ConsumerWidget {
  const _PermanentContractorGallerySection({required this.guid});

  final String guid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(
      permanentContractorGalleryListProvider(guid),
    );
    final localItems = ref.watch(
      permanentContractorGalleryLocalItemsProvider.select(
        (map) =>
            map[guid.trim()] ?? const <PermanentContractorGalleryItemEntity>[],
      ),
    );
    final deletedPhotoIds = ref.watch(
      permanentContractorGalleryDeletedPhotoIdsProvider.select(
        (map) => map[guid.trim()] ?? const <int>{},
      ),
    );
    final deletingPhotoId = ref.watch(
      permanentContractorCheckControllerProvider.select(
        (state) => state.deletingPhotoId,
      ),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return galleryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            toDisplayErrorMessage(
              error,
              fallback: 'Failed to load permanent contractor gallery.',
            ),
            style: TextStyle(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          AppFilledButton(
            onPressed: () =>
                ref.invalidate(permanentContractorGalleryListProvider(guid)),
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (items) {
        final merged = <PermanentContractorGalleryItemEntity>[
          ...items.where((item) => !deletedPhotoIds.contains(item.photoId)),
          ...localItems.where(
            (item) => !deletedPhotoIds.contains(item.photoId),
          ),
        ];
        if (merged.isEmpty) {
          return const Text('No photos uploaded for this session.');
        }
        return GalleryPhotoGrid(
          itemCount: merged.length,
          itemBuilder: (context, index) => _PermanentContractorGalleryThumb(
            guid: guid,
            item: merged[index],
            isDeleting: deletingPhotoId == merged[index].photoId,
          ),
        );
      },
    );
  }
}

class _PermanentContractorGalleryThumb extends ConsumerWidget {
  const _PermanentContractorGalleryThumb({
    required this.guid,
    required this.item,
    required this.isDeleting,
  });

  final String guid;
  final PermanentContractorGalleryItemEntity item;
  final bool isDeleting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBytes = ref.watch(
      permanentContractorGalleryPhotoProvider(
        PermanentContractorGalleryPhotoKey(photoId: item.photoId),
      ),
    );

    return GalleryPhotoTile(
      asyncBytes: asyncBytes,
      isDeleting: isDeleting,
      onDeleteTap: isDeleting
          ? null
          : () => _deleteGalleryPhoto(context, ref, guid: guid, item: item),
      deleteKey: Key('permanent-contractor-gallery-delete-${item.photoId}'),
    );
  }

  Future<void> _deleteGalleryPhoto(
    BuildContext context,
    WidgetRef ref, {
    required String guid,
    required PermanentContractorGalleryItemEntity item,
  }) async {
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
        .read(permanentContractorCheckControllerProvider.notifier)
        .deletePhoto(photoId: item.photoId);
    if (!context.mounted) {
      return;
    }

    if (!result.success) {
      showAppSnackBar(
        context,
        result.message.isEmpty
            ? 'Failed to delete permanent contractor photo.'
            : result.message,
      );
      return;
    }

    ref
        .read(permanentContractorGalleryLocalItemsProvider.notifier)
        .remove(guid: guid, photoId: item.photoId);
    ref
        .read(permanentContractorGalleryDeletedPhotoIdsProvider.notifier)
        .markDeleted(guid: guid, photoId: item.photoId);
    removePermanentContractorGalleryPhotoCache(ref, photoId: item.photoId);

    showAppSnackBar(
      context,
      result.message.isEmpty ? 'Photo deleted successfully.' : result.message,
    );
  }
}
