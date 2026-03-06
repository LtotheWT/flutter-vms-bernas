import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'app_filled_button.dart';
import 'app_outlined_button.dart';

class PhotoUploadRequestResult {
  const PhotoUploadRequestResult({
    required this.success,
    required this.message,
    required this.photoId,
  });

  final bool success;
  final String message;
  final int? photoId;
}

class PhotoUploadSheetResult {
  const PhotoUploadSheetResult({
    required this.message,
    required this.photoId,
    required this.photoDescription,
  });

  final String message;
  final int? photoId;
  final String photoDescription;
}

typedef PhotoUploadHandler =
    Future<PhotoUploadRequestResult> Function(String photoDescription);

Future<PhotoUploadSheetResult?> showPhotoUploadBottomSheet({
  required BuildContext context,
  required Uint8List imageBytes,
  required PhotoUploadHandler onUpload,
  String title = 'Upload Photo',
  String descriptionLabel = 'Photo Description (Optional)',
  String uploadButtonLabel = 'Upload',
  String failureFallback = 'Failed to upload photo.',
}) {
  return showModalBottomSheet<PhotoUploadSheetResult>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final descriptionController = TextEditingController();
      String? errorText;
      bool isUploading = false;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> upload() async {
            final photoDescription = descriptionController.text.trim();
            setSheetState(() {
              isUploading = true;
              errorText = null;
            });

            final result = await onUpload(photoDescription);
            if (!context.mounted) {
              return;
            }

            if (!result.success) {
              setSheetState(() {
                isUploading = false;
                errorText = result.message.trim().isEmpty
                    ? failureFallback
                    : result.message.trim();
              });
              return;
            }

            Navigator.of(sheetContext).pop(
              PhotoUploadSheetResult(
                message: result.message,
                photoId: result.photoId,
                photoDescription: photoDescription,
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
                    title,
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
                    decoration: InputDecoration(labelText: descriptionLabel),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
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
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(uploadButtonLabel),
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
