import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/widgets/order_cart_item_tile.dart';
import 'package:kasway/features/home/view/widgets/order_side_view.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  late HomeBloc homeBloc;

  setUp(() {
    homeBloc = MockHomeBloc();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider.value(
        value: homeBloc,
        child: const Scaffold(body: OrderSideView(showAppBar: true)),
      ),
    );
  }

  testWidgets('OrderSideView renders empty state correctly', (tester) async {
    when(() => homeBloc.state).thenReturn(const HomeState());

    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Order List'), findsOneWidget);
    // Proceed to Payment button should be disabled or present but not clickable logic handled inside
    expect(find.text('Proceed to Payment'), findsOneWidget);
  });

  testWidgets('OrderSideView renders cart items', (tester) async {
    final product = const Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
    );
    final cartItem = CartItem(product: product, quantity: 1);

    when(() => homeBloc.state).thenReturn(HomeState(cartItems: [cartItem]));

    await tester.pumpWidget(buildTestableWidget());

    expect(find.byType(OrderCartItemTile), findsOneWidget);
    expect(find.text('IDR 10.000'), findsAtLeastNWidgets(1));
  });

  testWidgets('OrderSideView clears order', (tester) async {
    when(() => homeBloc.state).thenReturn(const HomeState());

    await tester.pumpWidget(buildTestableWidget());

    await tester.tap(find.text('Clear Order'));
    await tester.pumpAndSettle();

    expect(find.text('Clear Order?'), findsOneWidget);

    await tester.tap(find.text('Clear Order').last); // Confirm dialog button
    verify(() => homeBloc.add(HomeCartCleared())).called(1);
  });
}
