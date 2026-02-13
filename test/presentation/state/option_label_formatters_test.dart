import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/presentation/state/option_label_formatters.dart';

void main() {
  test('labelOrBlank returns blank token for empty strings', () {
    expect(labelOrBlank(''), '(Blank)');
    expect(labelOrBlank('   '), '(Blank)');
    expect(labelOrBlank('ADC'), 'ADC');
  });

  test('siteLabel prefers label then falls back to value', () {
    expect(
      siteLabel(value: 'FACTORY1', label: 'FACTORY1 - FACTORY1 T'),
      'FACTORY1 - FACTORY1 T',
    );
    expect(siteLabel(value: 'FACTORY1', label: ''), 'FACTORY1');
    expect(siteLabel(value: '', label: ''), '(Blank)');
  });

  test('visitorTypeLabel prefers description then falls back to value', () {
    expect(
      visitorTypeLabel(value: '1_Visitor', label: 'Visitor/Vendor/Forwarder'),
      'Visitor/Vendor/Forwarder',
    );
    expect(visitorTypeLabel(value: '1_Visitor', label: ''), '1_Visitor');
    expect(visitorTypeLabel(value: '', label: ''), '(Blank)');
  });

  test('hostLabel formats name and id combinations', () {
    expect(
      hostLabel(employeeId: 'EMP0001', employeeName: 'Suraya'),
      'Suraya (EMP0001)',
    );
    expect(hostLabel(employeeId: '', employeeName: 'Suraya'), 'Suraya');
    expect(hostLabel(employeeId: 'EMP0001', employeeName: ''), 'EMP0001');
    expect(hostLabel(employeeId: '', employeeName: ''), '(Blank)');
  });
}
