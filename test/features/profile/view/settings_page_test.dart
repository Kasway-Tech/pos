import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/features/profile/view/settings_page.dart';

void main() {
  testWidgets('SettingsPage renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Printer'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('SettingsPage respects max width constraint', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    final constrainedBox = tester.widget<ConstrainedBox>(
      find.byType(ConstrainedBox).first,
    );
    expect(constrainedBox.constraints.maxWidth, 600);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
