import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/features/profile/view/help_support_page.dart';

void main() {
  testWidgets('HelpSupportPage renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpSupportPage()));

    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('How to place an order?'), findsOneWidget);
  });

  testWidgets('HelpSupportPage respects max width constraint', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: HelpSupportPage()));

    final constrainedBox = tester.widget<ConstrainedBox>(
      find.byKey(const Key('content_constraint')),
    );
    expect(constrainedBox.constraints.maxWidth, 600);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
