import 'package:flutter/material.dart';
import 'package:kasway/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final key = GlobalKey<ScaffoldMessengerState>();
    await tester.pumpWidget(App(scaffoldMessengerKey: key));

    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}
