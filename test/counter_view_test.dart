import 'package:atomikpos/features/counter/view/counter_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterPage', () {
    testWidgets('renders CounterView', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterPage()));
      expect(find.byType(CounterView), findsOneWidget);
    });
  });

  group('CounterView', () {
    testWidgets('renders current value', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterPage()));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('tapping increment button updates value', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterPage()));

      await tester.tap(
        find.byKey(const Key('counterView_increment_floatingActionButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tapping decrement button updates value', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterPage()));

      await tester.tap(
        find.byKey(const Key('counterView_decrement_floatingActionButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('-1'), findsOneWidget);
    });
  });
}
