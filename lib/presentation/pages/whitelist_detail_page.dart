import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/whitelist_gallery_item_entity.dart';
import '../../domain/entities/whitelist_save_photo_submission_entity.dart';
import '../services/camera_capture_service.dart';
import '../state/auth_session_providers.dart';
import '../state/device_service_providers.dart';
import '../state/photo_cache_helpers.dart';
import '../state/whitelist_detail_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_outlined_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/gallery_photo_tile.dart';
import '../widgets/gallery_photo_grid.dart';
import '../widgets/info_row.dart';
import '../widgets/photo_upload_bottom_sheet.dart';

@immutable
class WhitelistDetailRouteArgs {
  const WhitelistDetailRouteArgs({
    required this.entity,
    required this.vehiclePlate,
    required this.checkType,
  });

  final String entity;
  final String vehiclePlate;
  final String checkType;
}

@immutable
class WhitelistDetailPageResult {
  const WhitelistDetailPageResult({
    required this.shouldRefresh,
    this.message = '',
  });

  final bool shouldRefresh;
  final String message;
}

class WhitelistDetailPage extends ConsumerStatefulWidget {
  const WhitelistDetailPage({
    super.key,
    required this.args,
    this.cameraLauncher,
  });

  final WhitelistDetailRouteArgs args;
  final Future<XFile?> Function(BuildContext context)? cameraLauncher;

  @override
  ConsumerState<WhitelistDetailPage> createState() =>
      _WhitelistDetailPageState();
}

class _WhitelistDetailPageState extends ConsumerState<WhitelistDetailPage> {
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref
          .read(whitelistDetailControllerProvider.notifier)
          .load(
            entity: widget.args.entity,
            vehiclePlate: widget.args.vehiclePlate,
            checkType: widget.args.checkType,
          );
    });
  }

  String get _normalizedCheckType => widget.args.checkType.trim().toUpperCase();

  String get _checkTypeDisplay =>
      _normalizedCheckType == 'O' ? 'Check-Out' : 'Check-In';

  String _displayOrDash(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  String get _submitSuccessFallback => _normalizedCheckType == 'O'
      ? 'Whitelist checked OUT successfully.'
      : 'Whitelist checked IN successfully.';

  Future<void> _captureFromCamera() async {
    final state = ref.read(whitelistDetailControllerProvider);
    final detail = state.detail;
    final guid = state.photoSessionGuid?.trim() ?? '';
    if (detail == null || guid.isEmpty) {
      showAppSnackBar(context, 'Please load whitelist detail before upload.');
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
          final submission = WhitelistSavePhotoSubmissionEntity(
            imageBase64: base64Encode(bytes),
            photoDescription: photoDescription,
            guid: guid,
            entity: entity,
            site: site,
            uploadedBy: uploadedBy,
          );
          final result = await ref
              .read(whitelistDetailControllerProvider.notifier)
              .savePhoto(submission: submission);
          return PhotoUploadRequestResult(
            success: result.success,
            message: result.message,
            photoId: result.photoId,
          );
        },
        failureFallback: 'Failed to upload whitelist photo.',
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
            .read(whitelistGalleryLocalItemsProvider.notifier)
            .append(
              guid: guid,
              item: WhitelistGalleryItemEntity(
                photoId: uploaded.photoId!,
                photoDesc: uploaded.photoDescription,
                url: '/Whitelist/photo/${uploaded.photoId}',
              ),
            );
        seedWhitelistGalleryPhotoCache(
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

  Future<void> _onConfirm() async {
    final result = await ref
        .read(whitelistDetailControllerProvider.notifier)
        .submit();
    if (!mounted) {
      return;
    }
    final trimmedMessage = result.message.trim();
    var message = trimmedMessage;
    if (message.isEmpty) {
      message = result.status
          ? _submitSuccessFallback
          : 'Failed to submit whitelist.';
    }
    if (result.status) {
      _popWithResult(
        WhitelistDetailPageResult(shouldRefresh: true, message: message),
      );
      return;
    }
    showAppSnackBar(context, message);
  }

  void _popWithResult(WhitelistDetailPageResult result) {
    if (_allowPop) {
      return;
    }
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whitelistDetailControllerProvider);
    final detail = state.detail;
    final photoSessionGuid = state.photoSessionGuid?.trim() ?? '';
    final canSubmit = detail != null && !state.isLoading && !state.isSubmitting;
    final submitLabel = _normalizedCheckType == 'O'
        ? 'Confirm Check-Out'
        : 'Confirm Check-In';

    return PopScope<WhitelistDetailPageResult>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _popWithResult(const WhitelistDetailPageResult(shouldRefresh: false));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Whitelist Details')),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppFilledButton(
            onPressed: canSubmit ? _onConfirm : null,
            child: state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(submitLabel),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            if (state.isLoading && !state.hasLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (state.errorMessage?.trim().isNotEmpty == true &&
                  detail == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppOutlinedButton(
                          onPressed: () {
                            ref
                                .read(
                                  whitelistDetailControllerProvider.notifier,
                                )
                                .load(
                                  entity: widget.args.entity,
                                  vehiclePlate: widget.args.vehiclePlate,
                                  checkType: widget.args.checkType,
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      InfoRow(label: 'Check Type', value: _checkTypeDisplay),
                      InfoRow(
                        label: 'Vehicle number',
                        value: _displayOrDash(
                          detail?.vehiclePlate ?? widget.args.vehiclePlate,
                        ),
                      ),
                      InfoRow(
                        label: 'IC/Passport',
                        value: _displayOrDash(detail?.ic ?? ''),
                      ),
                      InfoRow(
                        label: 'Name',
                        value: _displayOrDash(detail?.name ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppOutlinedButtonIcon(
                          onPressed:
                              state.isUploadingPhoto ||
                                  state.isLoading ||
                                  photoSessionGuid.isEmpty
                              ? null
                              : _captureFromCamera,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(height: 12),
                        _WhitelistGallerySection(guid: photoSessionGuid),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _WhitelistGallerySection extends ConsumerWidget {
  const _WhitelistGallerySection({required this.guid});

  final String guid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(whitelistGalleryListProvider(guid));
    final localItems = ref.watch(
      whitelistGalleryLocalItemsProvider.select(
        (map) => map[guid.trim()] ?? const <WhitelistGalleryItemEntity>[],
      ),
    );
    final deletedPhotoIds = ref.watch(
      whitelistGalleryDeletedPhotoIdsProvider.select(
        (map) => map[guid.trim()] ?? const <int>{},
      ),
    );
    final deletingPhotoId = ref.watch(
      whitelistDetailControllerProvider.select(
        (state) => state.deletingPhotoId,
      ),
    );

    return galleryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _toErrorMessage(
              error,
              fallback: 'Failed to load whitelist gallery.',
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          AppOutlinedButton(
            onPressed: () => ref.invalidate(whitelistGalleryListProvider(guid)),
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
          itemBuilder: (context, index) => _WhitelistGalleryThumb(
            guid: guid,
            item: items[index],
            isDeleting: deletingPhotoId == items[index].photoId,
          ),
        );
      },
    );
  }

  String _toErrorMessage(Object error, {required String fallback}) {
    return toDisplayErrorMessage(error, fallback: fallback);
  }
}

class _WhitelistGalleryThumb extends ConsumerWidget {
  const _WhitelistGalleryThumb({
    required this.guid,
    required this.item,
    required this.isDeleting,
  });

  final String guid;
  final WhitelistGalleryItemEntity item;
  final bool isDeleting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(
      whitelistGalleryPhotoProvider(
        WhitelistGalleryPhotoKey(photoId: item.photoId),
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
          .read(whitelistDetailControllerProvider.notifier)
          .deletePhoto(photoId: item.photoId);
      if (!context.mounted) {
        return;
      }
      if (!result.success) {
        showAppSnackBar(
          context,
          result.message.isEmpty
              ? 'Failed to delete whitelist photo. Please try again.'
              : result.message,
        );
        return;
      }

      ref
          .read(whitelistGalleryLocalItemsProvider.notifier)
          .remove(guid: guid, photoId: item.photoId);
      ref
          .read(whitelistGalleryDeletedPhotoIdsProvider.notifier)
          .markDeleted(guid: guid, photoId: item.photoId);
      removeWhitelistGalleryPhotoCache(ref, photoId: item.photoId);
      showAppSnackBar(
        context,
        result.message.isEmpty ? 'Photo deleted successfully.' : result.message,
      );
    }

    return GalleryPhotoTile(
      asyncBytes: photoAsync,
      isDeleting: isDeleting,
      onDeleteTap: deletePhoto,
      deleteKey: Key('whitelist-gallery-delete-${item.photoId}'),
    );
  }
}
