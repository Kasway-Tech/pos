import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/features/profile/view/profile_page.dart';

void main() {
  testWidgets('ProfilePage renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('ProfilePage has max width constraint logic', (tester) async {
    // Set a large screen size
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    // Check for ConstrainedBox with maxWidth 600
    // This is checking the widget tree structure implementation
    final constrainedBoxFinder = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox && widget.constraints.maxWidth == 600.0,
    );

    expect(constrainedBoxFinder, findsOneWidget);

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
}
