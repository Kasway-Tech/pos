import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/features/profile/view/order_history_page.dart';

void main() {
  testWidgets('OrderHistoryPage renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OrderHistoryPage()));

    expect(find.text('Order History'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(Card), findsAtLeastNWidgets(1));
  });

  testWidgets('OrderHistoryPage respects max width constraint', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: OrderHistoryPage()));

    final constrainedBox = tester.widget<ConstrainedBox>(
      find.byType(ConstrainedBox).first,
    );
    expect(constrainedBox.constraints.maxWidth, 600);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
