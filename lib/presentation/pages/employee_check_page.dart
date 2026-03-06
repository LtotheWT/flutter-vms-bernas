import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/date_time_formats.dart';
import '../../core/error_messages.dart';
import '../../domain/entities/employee_gallery_item_entity.dart';
import '../../domain/entities/employee_save_photo_submission_entity.dart';
import '../services/camera_capture_service.dart';
import '../services/mobile_scanner_launcher.dart';
import '../state/auth_session_providers.dart';
import '../state/device_service_providers.dart';
import '../state/employee_check_providers.dart';
import '../state/photo_cache_helpers.dart';
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

class EmployeeCheckPage extends ConsumerStatefulWidget {
  const EmployeeCheckPage({
    super.key,
    required this.initialCheckType,
    this.scanLauncher,
    this.cameraLauncher,
  });

  final EmployeeCheckType initialCheckType;
  final Future<String?> Function(BuildContext context)? scanLauncher;
  final Future<XFile?> Function(BuildContext context)? cameraLauncher;

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

  Future<void> _captureFromCamera() async {
    final state = ref.read(employeeCheckControllerProvider);
    final info = state.info;
    final guid = state.photoSessionGuid.trim();
    if (info == null || info.employeeId.trim().isEmpty || guid.isEmpty) {
      showAppSnackBar(context, 'Please search employee info before upload.');
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
          final submission = EmployeeSavePhotoSubmissionEntity(
            imageBase64: base64Encode(bytes),
            photoDescription: photoDescription,
            guid: guid,
            entity: entity,
            site: site,
            uploadedBy: uploadedBy,
          );
          final result = await ref
              .read(employeeCheckControllerProvider.notifier)
              .savePhoto(submission: submission);
          return PhotoUploadRequestResult(
            success: result.success,
            message: result.message,
            photoId: result.photoId,
          );
        },
        failureFallback: 'Failed to upload employee photo.',
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
            .read(employeeGalleryLocalItemsProvider.notifier)
            .append(
              guid: guid,
              item: EmployeeGalleryItemEntity(
                photoId: uploaded.photoId!,
                photoDesc: uploaded.photoDescription,
                url: '/Employee/photo/${uploaded.photoId}',
              ),
            );
        seedEmployeeGalleryPhotoCache(
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
    if (result.status) {
      ref
          .read(employeeCheckControllerProvider.notifier)
          .resetAfterSuccessfulSubmit();
    }
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
          if (state.info != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppOutlinedButtonIcon(
                      key: const Key('employee-gallery-camera-button'),
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
                    _EmployeeGallerySection(
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

class _EmployeeGallerySection extends ConsumerWidget {
  const _EmployeeGallerySection({required this.guid});

  final String guid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(employeeGalleryListProvider(guid));
    final localItems = ref.watch(
      employeeGalleryLocalItemsProvider.select(
        (map) => map[guid.trim()] ?? const <EmployeeGalleryItemEntity>[],
      ),
    );
    final deletedPhotoIds = ref.watch(
      employeeGalleryDeletedPhotoIdsProvider.select(
        (map) => map[guid.trim()] ?? const <int>{},
      ),
    );
    final deletingPhotoId = ref.watch(
      employeeCheckControllerProvider.select((state) => state.deletingPhotoId),
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
              fallback: 'Failed to load employee gallery.',
            ),
            style: TextStyle(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          AppOutlinedButton(
            onPressed: () => ref.invalidate(employeeGalleryListProvider(guid)),
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (remoteItems) {
        final items = mergeGalleryItemsByPhotoId(
          remoteItems: remoteItems,
          localItems: localItems,
          deletedPhotoIds: deletedPhotoIds,
          photoIdOf: (item) => item.photoId,
        );

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No photos uploaded for this session.'),
          );
        }

        return GalleryPhotoGrid(
          itemCount: items.length,
          itemBuilder: (context, index) => _EmployeeGalleryThumb(
            guid: guid,
            item: items[index],
            isDeleting: deletingPhotoId == items[index].photoId,
          ),
        );
      },
    );
  }
}

class _EmployeeGalleryThumb extends ConsumerWidget {
  const _EmployeeGalleryThumb({
    required this.guid,
    required this.item,
    required this.isDeleting,
  });

  final String guid;
  final EmployeeGalleryItemEntity item;
  final bool isDeleting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(
      employeeGalleryPhotoProvider(
        EmployeeGalleryPhotoKey(photoId: item.photoId),
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
          .read(employeeCheckControllerProvider.notifier)
          .deletePhoto(photoId: item.photoId);
      if (!context.mounted) {
        return;
      }
      if (!result.success) {
        showAppSnackBar(
          context,
          result.message.isEmpty
              ? 'Failed to delete employee photo. Please try again.'
              : result.message,
        );
        return;
      }

      ref
          .read(employeeGalleryLocalItemsProvider.notifier)
          .remove(guid: guid, photoId: item.photoId);
      ref
          .read(employeeGalleryDeletedPhotoIdsProvider.notifier)
          .markDeleted(guid: guid, photoId: item.photoId);
      removeEmployeeGalleryPhotoCache(ref, photoId: item.photoId);
      showAppSnackBar(
        context,
        result.message.isEmpty ? 'Photo deleted successfully.' : result.message,
      );
    }

    return GalleryPhotoTile(
      asyncBytes: photoAsync,
      isDeleting: isDeleting,
      onDeleteTap: deletePhoto,
      deleteKey: Key('employee-gallery-delete-${item.photoId}'),
    );
  }
}
