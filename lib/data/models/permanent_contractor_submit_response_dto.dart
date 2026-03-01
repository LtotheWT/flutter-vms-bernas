import '../../domain/entities/permanent_contractor_submit_result_entity.dart';

class PermanentContractorSubmitResponseDto {
  const PermanentContractorSubmitResponseDto({
    required this.status,
    required this.message,
  });

  final bool status;
  final String message;

  factory PermanentContractorSubmitResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final rootStatus = json['Status'] == true;
    final rootMessage = _asString(json['Message']);

    final detailsValue = json['Details'];
    if (detailsValue is Map) {
      final details = detailsValue.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final detailsStatus = details['Success'] == true;
      final detailsMessage = _asString(details['Message']);
      return PermanentContractorSubmitResponseDto(
        status: detailsStatus,
        message: detailsMessage.isNotEmpty ? detailsMessage : rootMessage,
      );
    }

    if (json.containsKey('Success')) {
      final success = json['Success'] == true;
      return PermanentContractorSubmitResponseDto(
        status: success,
        message: rootMessage,
      );
    }

    return PermanentContractorSubmitResponseDto(
      status: rootStatus,
      message: rootMessage,
    );
  }

  PermanentContractorSubmitResultEntity toEntity() {
    return PermanentContractorSubmitResultEntity(
      status: status,
      message: message,
    );
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }
}
