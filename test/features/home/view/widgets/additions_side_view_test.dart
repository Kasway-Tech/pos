import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/view/widgets/additions_side_view.dart';

void main() {
  testWidgets('AdditionsSideView renders correctly', (tester) async {
    final addition = const Addition(id: 'a1', name: 'Extra Cheese', price: 500);
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
      additions: [addition],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdditionsSideView(
            product: product,
            onConfirm: (_) {},
            onBack: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Extra Cheese'), findsOneWidget);
    expect(find.text('Add to Order'), findsOneWidget);
  });

  testWidgets('AdditionsSideView handles selection', (tester) async {
    final addition = const Addition(id: 'a1', name: 'Extra Cheese', price: 500);
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
      additions: [addition],
    );

    List<Addition>? selectedAdditions;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdditionsSideView(
            product: product,
            onConfirm: (additions) => selectedAdditions = additions,
            onBack: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Extra Cheese'));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Add to Order'));

    expect(selectedAdditions, isNotNull);
    expect(selectedAdditions!.length, 1);
    expect(selectedAdditions!.first, addition);
  });
}
