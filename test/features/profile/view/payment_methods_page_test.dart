import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/features/profile/view/payment_methods_page.dart';

void main() {
  testWidgets('PaymentMethodsPage renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PaymentMethodsPage()));

    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('Visa'), findsOneWidget);
    expect(find.text('Mastercard'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
  });

  testWidgets('PaymentMethodsPage respects max width constraint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(home: PaymentMethodsPage()));

    final constrainedBox = tester.widget<ConstrainedBox>(
      find.byKey(const Key('content_constraint')),
    );
    expect(constrainedBox.constraints.maxWidth, 600);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
