import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_bernas/presentation/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('renders operations, report and profile destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
