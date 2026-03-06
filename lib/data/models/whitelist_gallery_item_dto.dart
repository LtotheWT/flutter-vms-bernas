import '../../domain/entities/whitelist_gallery_item_entity.dart';

class WhitelistGalleryItemDto {
  const WhitelistGalleryItemDto({
    required this.photoId,
    required this.photoDesc,
    required this.url,
  });

  final int photoId;
  final String photoDesc;
  final String url;

  factory WhitelistGalleryItemDto.fromJson(Map<String, dynamic> json) {
    return WhitelistGalleryItemDto(
      photoId: _asInt(json['photoId']),
      photoDesc: _asString(json['photoDesc']),
      url: _asString(json['Url']),
    );
  }

  WhitelistGalleryItemEntity toEntity() {
    return WhitelistGalleryItemEntity(
      photoId: photoId,
      photoDesc: photoDesc,
      url: url,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
