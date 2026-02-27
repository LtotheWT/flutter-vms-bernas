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
