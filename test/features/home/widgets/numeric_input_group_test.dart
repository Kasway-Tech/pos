import 'package:atomikpos/features/home/view/widgets/numeric_input_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumericInputGroup', () {
    testWidgets('increments value when add button is pressed', (tester) async {
      int value = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputGroup(value: value, onChanged: (v) => value = v),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(value, 2);
    });

    testWidgets('decrements value when remove button is pressed', (
      tester,
    ) async {
      int value = 5;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputGroup(value: value, onChanged: (v) => value = v),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      expect(value, 4);
    });

    testWidgets('cannot decrement below min', (tester) async {
      int value = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputGroup(
              value: value,
              onChanged: (v) => value = v,
              min: 0,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      expect(value, 0);
    });

    testWidgets('updates value when text is entered', (tester) async {
      int value = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericInputGroup(value: value, onChanged: (v) => value = v),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '10');
      expect(value, 10);
    });
  });
}
