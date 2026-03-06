import 'dart:typed_data';

Future<Uint8List?> fetchPhotoWithMemoryCache({
  required Map<String, Uint8List?> cache,
  required String cacheKey,
  required Future<Uint8List?> Function() loader,
}) async {
  if (cache.containsKey(cacheKey)) {
    return cache[cacheKey];
  }

  final bytes = await loader();
  cache[cacheKey] = bytes;
  return bytes;
}

String galleryPhotoCacheKey(int photoId) => 'gallery-photo-$photoId';

void seedPhotoMemoryCache(
  Map<String, Uint8List?> cache, {
  required String cacheKey,
  required Uint8List bytes,
}) {
  if (cacheKey.trim().isEmpty || bytes.isEmpty) {
    return;
  }
  cache[cacheKey] = bytes;
}

void removePhotoMemoryCache(
  Map<String, Uint8List?> cache, {
  required String cacheKey,
}) {
  if (cacheKey.trim().isEmpty) {
    return;
  }
  cache.remove(cacheKey);
}

List<T> mergeGalleryItemsByPhotoId<T>({
  required List<T> remoteItems,
  required List<T> localItems,
  required Set<int> deletedPhotoIds,
  required int Function(T item) photoIdOf,
}) {
  final seen = <int>{};
  final merged = <T>[];
  for (final item in [...localItems, ...remoteItems]) {
    final photoId = photoIdOf(item);
    if (deletedPhotoIds.contains(photoId)) {
      continue;
    }
    if (seen.add(photoId)) {
      merged.add(item);
    }
  }
  merged.sort((left, right) => photoIdOf(left).compareTo(photoIdOf(right)));
  return merged;
}
