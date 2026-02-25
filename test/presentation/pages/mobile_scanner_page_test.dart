import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/presentation/pages/mobile_scanner_page.dart';

void main() {
  testWidgets('renders title and description', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MobileScannerPage(
          title: 'Scan QR Code',
          description: 'Align QR code inside the frame to scan.',
          scannerBuilder: _fakeScannerBuilder,
        ),
      ),
    );

    expect(find.text('Scan QR Code'), findsOneWidget);
    expect(
      find.text('Align QR code inside the frame to scan.'),
      findsOneWidget,
    );
  });

  testWidgets('close action pops without value', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const MobileScannerPage(
                        title: 'Scan QR Code',
                        scannerBuilder: _fakeScannerBuilder,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close scanner'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('accepts first scanned value only', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const MobileScannerPage(
                        title: 'Scan QR Code',
                        scannerBuilder: _multiScanBuilder,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emit Twice'));
    await tester.pumpAndSettle();

    expect(result, 'VIS|FIRST|A|F');
  });
}

Widget _fakeScannerBuilder(
  void Function(String value) onScanned,
  void Function(String message) onError,
) {
  return const ColoredBox(color: Colors.black);
}

Widget _multiScanBuilder(
  void Function(String value) onScanned,
  void Function(String message) onError,
) {
  return Center(
    child: ElevatedButton(
      onPressed: () {
        onScanned('VIS|FIRST|A|F');
        onScanned('VIS|SECOND|A|F');
      },
      child: const Text('Emit Twice'),
    ),
  );
}
