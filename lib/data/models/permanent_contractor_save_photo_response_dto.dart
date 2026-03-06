import '../../domain/entities/permanent_contractor_save_photo_result_entity.dart';

class PermanentContractorSavePhotoResponseDto {
  const PermanentContractorSavePhotoResponseDto({
    required this.success,
    required this.message,
    required this.photoId,
  });

  final bool success;
  final String? message;
  final int? photoId;

  factory PermanentContractorSavePhotoResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return PermanentContractorSavePhotoResponseDto(
      success: _asBool(json['success']),
      message: _asStringOrNull(json['message']),
      photoId: _extractPhotoId(json['data']),
    );
  }

  PermanentContractorSavePhotoResultEntity toEntity() {
    return PermanentContractorSavePhotoResultEntity(
      success: success,
      message: message?.trim() ?? '',
      photoId: photoId,
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String? _asStringOrNull(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static int? _extractPhotoId(dynamic data) {
    if (data is! Map) {
      return null;
    }
    final map = data.map((key, value) => MapEntry(key.toString(), value));
    final value = map['PhotoId'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString().trim() ?? '');
  }
}
