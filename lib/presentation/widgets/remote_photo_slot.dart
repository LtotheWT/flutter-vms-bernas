import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemotePhotoSlot extends StatelessWidget {
  const RemotePhotoSlot({
    super.key,
    required this.asyncBytes,
    this.size = 72,
    this.thumbnailKey,
    this.fullscreenKey,
  });

  final AsyncValue<Uint8List?> asyncBytes;
  final double size;
  final Key? thumbnailKey;
  final Key? fullscreenKey;

  @override
  Widget build(BuildContext context) {
    return asyncBytes.when(
      data: (bytes) {
        if (bytes == null || bytes.isEmpty) {
          return _PhotoPlaceholder(size: size);
        }
        return GestureDetector(
          key: thumbnailKey,
          onTap: () {
            showDialog<void>(
              context: context,
              barrierColor: Colors.black87,
              builder: (_) => _FullScreenPhotoDialog(
                bytes: bytes,
                dialogKey: fullscreenKey,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: size,
              width: size,
              child: Image.memory(bytes, fit: BoxFit.cover),
            ),
          ),
        );
      },
      error: (_, __) => _PhotoPlaceholder(size: size),
      loading: () => Stack(
        alignment: Alignment.center,
        children: [
          _PhotoPlaceholder(size: size),
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: size,
        width: size,
        child: ColoredBox(
          color: Colors.grey.shade300,
          child: const Icon(Icons.person, size: 30, color: Colors.black54),
        ),
      ),
    );
  }
}

class _FullScreenPhotoDialog extends StatelessWidget {
  const _FullScreenPhotoDialog({required this.bytes, this.dialogKey});

  final Uint8List bytes;
  final Key? dialogKey;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: dialogKey,
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              tooltip: 'Close photo',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
