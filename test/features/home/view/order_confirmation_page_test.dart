import 'package:atomikpos/data/models/cart_item.dart';
import 'package:atomikpos/data/models/product.dart';
import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:atomikpos/features/home/view/order_confirmation_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  late HomeBloc homeBloc;
  final product = Product(
    id: '1',
    name: 'Test Product',
    price: 15000,
    imageUrl: '',
  );

  setUp(() {
    homeBloc = MockHomeBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider.value(
        value: homeBloc,
        child: const OrderConfirmationPage(),
      ),
    );
  }

  testWidgets('renders all major components', (tester) async {
    when(() => homeBloc.state).thenReturn(
      HomeState(cartItems: [CartItem(product: product, quantity: 2)]),
    );

    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Order List'), findsOneWidget);
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Confirm Order'), findsOneWidget);
    expect(
      find.byType(ListView),
      findsNWidgets(2),
    ); // Item list and Summary list
  });

  testWidgets('displays correct total', (tester) async {
    when(() => homeBloc.state).thenReturn(
      HomeState(cartItems: [CartItem(product: product, quantity: 2)]),
    );

    await tester.pumpWidget(buildTestableWidget());

    // Total should be 15000 * 2 = 30000
    expect(find.textContaining('30.000'), findsAtLeastNWidgets(1));
  });
}
