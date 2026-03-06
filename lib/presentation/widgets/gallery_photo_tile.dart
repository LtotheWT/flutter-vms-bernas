import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_photo_slot.dart';

class GalleryPhotoTile extends StatelessWidget {
  const GalleryPhotoTile({
    super.key,
    required this.asyncBytes,
    required this.isDeleting,
    required this.onDeleteTap,
    this.size = 72,
    this.thumbnailKey,
    this.fullscreenKey,
    this.deleteKey,
  });

  final AsyncValue<Uint8List?> asyncBytes;
  final bool isDeleting;
  final VoidCallback? onDeleteTap;
  final double size;
  final Key? thumbnailKey;
  final Key? fullscreenKey;
  final Key? deleteKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemotePhotoSlot(
            asyncBytes: asyncBytes,
            size: size,
            thumbnailKey: thumbnailKey,
            fullscreenKey: fullscreenKey,
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              key: deleteKey,
              onTap: isDeleting ? null : onDeleteTap,
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
      ),
    );
  }
}
