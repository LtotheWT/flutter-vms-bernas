import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/data/models/ref_visitor_type_dto.dart';

void main() {
  test('parses normal visitor type row', () {
    const json = {
      'visitor_type': '1_Visitor',
      'type_desc': 'Visitor/Vendor/Forwarder',
    };

    final dto = RefVisitorTypeDto.fromJson(json);

    expect(dto.visitorType, '1_Visitor');
    expect(dto.typeDesc, 'Visitor/Vendor/Forwarder');
    expect(dto.toEntity().visitorType, '1_Visitor');
  });

  test('keeps blank visitor type row values from API', () {
    const json = {'visitor_type': '', 'type_desc': ''};

    final dto = RefVisitorTypeDto.fromJson(json);

    expect(dto.visitorType, isEmpty);
    expect(dto.typeDesc, isEmpty);
  });
}
