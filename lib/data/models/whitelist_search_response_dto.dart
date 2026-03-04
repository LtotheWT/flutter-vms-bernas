import 'whitelist_search_item_dto.dart';

class WhitelistSearchResponseDto {
  const WhitelistSearchResponseDto({
    required this.status,
    required this.message,
    required this.details,
  });

  final bool status;
  final String? message;
  final List<WhitelistSearchItemDto> details;

  factory WhitelistSearchResponseDto.fromJson(Map<String, dynamic> json) {
    final detailsValue = json['Details'];
    final details = detailsValue is List
        ? detailsValue
              .whereType<Map>()
              .map(
                (item) => WhitelistSearchItemDto.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList(growable: false)
        : const <WhitelistSearchItemDto>[];

    return WhitelistSearchResponseDto(
      status: json['Status'] == true,
      message: _asNullableString(json['Message']),
      details: details,
    );
  }

  static String? _asNullableString(Object? value) {
    final text = (value as String? ?? '').trim();
    return text.isEmpty ? null : text;
  }
}
