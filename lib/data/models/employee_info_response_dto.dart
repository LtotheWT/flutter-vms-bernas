import '../../domain/entities/employee_info_entity.dart';

class EmployeeInfoResponseDto {
  const EmployeeInfoResponseDto({
    required this.status,
    required this.message,
    required this.details,
  });

  final bool status;
  final String? message;
  final EmployeeInfoDto? details;

  factory EmployeeInfoResponseDto.fromJson(Map<String, dynamic> json) {
    final detailsValue = json['Details'];
    return EmployeeInfoResponseDto(
      status: json['Status'] == true,
      message: _asNullableString(json['Message']),
      details: detailsValue is Map
          ? EmployeeInfoDto.fromJson(
              detailsValue.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
    );
  }

  static String? _asNullableString(Object? value) {
    final text = (value as String? ?? '').trim();
    return text.isEmpty ? null : text;
  }
}

class EmployeeInfoDto {
  const EmployeeInfoDto({
    required this.employeeId,
    required this.employeeName,
    required this.site,
    required this.department,
    required this.unit,
    required this.vehicleType,
    required this.handphoneNo,
    required this.telNoExtension,
    required this.effectiveWorkingDate,
    required this.lastWorkingDate,
  });

  final String employeeId;
  final String employeeName;
  final String site;
  final String department;
  final String unit;
  final String vehicleType;
  final String handphoneNo;
  final String telNoExtension;
  final String effectiveWorkingDate;
  final String lastWorkingDate;

  factory EmployeeInfoDto.fromJson(Map<String, dynamic> json) {
    return EmployeeInfoDto(
      employeeId: _asString(json['EMP_ID']),
      employeeName: _asString(json['EMP_NAME']),
      site: _asString(json['SITE']),
      department: _asString(json['DEPT']),
      unit: _asString(json['UNIT']),
      vehicleType: _asString(json['VEHICLE_TYPE']),
      handphoneNo: _asString(json['HP_NO']),
      telNoExtension: _asString(json['TEL_NO']),
      effectiveWorkingDate: _asString(json['START_WORKING_DATE']),
      lastWorkingDate: _asString(json['LAST_WORKING_DATE']),
    );
  }

  EmployeeInfoEntity toEntity() {
    return EmployeeInfoEntity(
      employeeId: employeeId,
      employeeName: employeeName,
      site: site,
      department: department,
      unit: unit,
      vehicleType: vehicleType,
      handphoneNo: handphoneNo,
      telNoExtension: telNoExtension,
      effectiveWorkingDate: effectiveWorkingDate,
      lastWorkingDate: lastWorkingDate,
    );
  }

  static String _asString(Object? value) => (value as String? ?? '').trim();
}
