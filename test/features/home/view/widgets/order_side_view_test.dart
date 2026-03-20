import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/widgets/order_cart_item_tile.dart';
import 'package:kasway/features/home/view/widgets/order_side_view.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockNetworkCubit extends MockCubit<NetworkState>
    implements NetworkCubit {}

class MockTableCubit extends MockCubit<TableState> implements TableCubit {}

void main() {
  late MockHomeBloc homeBloc;
  late MockCurrencyCubit currencyCubit;
  late MockNetworkCubit networkCubit;
  late MockTableCubit tableCubit;

  setUp(() {
    homeBloc = MockHomeBloc();
    currencyCubit = MockCurrencyCubit();
    networkCubit = MockNetworkCubit();
    tableCubit = MockTableCubit();

    // IDR selected: formatPrice falls back to IDR directly (no exchange rate needed)
    when(() => currencyCubit.state).thenReturn(
      const CurrencyState(
        selectedCurrency: Currency(
          code: 'IDR',
          name: 'Indonesian Rupiah',
          flag: '🇮🇩',
        ),
      ),
    );
    when(() => networkCubit.state).thenReturn(const NetworkState());
    // Table layout disabled by default so it doesn't affect existing tests.
    when(() => tableCubit.state).thenReturn(const TableState());
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<CurrencyCubit>.value(value: currencyCubit),
          BlocProvider<NetworkCubit>.value(value: networkCubit),
          BlocProvider<TableCubit>.value(value: tableCubit),
        ],
        child: const Scaffold(body: OrderSideView(showAppBar: true)),
      ),
    );
  }

  testWidgets('OrderSideView renders empty state correctly', (tester) async {
    when(() => homeBloc.state).thenReturn(const HomeState());

    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Order List'), findsOneWidget);
    // Proceed to Payment button visible because screenWidth >= 800 in test environment
    expect(find.text('Proceed to Payment'), findsOneWidget);
  });

  testWidgets('OrderSideView renders cart items', (tester) async {
    const product = Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
    );
    final cartItem = CartItem(product: product, quantity: 1);

    when(() => homeBloc.state).thenReturn(HomeState(cartItems: [cartItem]));

    await tester.pumpWidget(buildTestableWidget());

    expect(find.byType(OrderCartItemTile), findsOneWidget);
    expect(find.textContaining('10.000'), findsAtLeastNWidgets(1));
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
