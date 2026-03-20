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
import 'package:kasway/features/home/view/order_confirmation_page.dart';
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

  final product = Product(
    id: '1',
    name: 'Test Product',
    price: 15000,
    imageUrl: '',
  );

  setUp(() {
    homeBloc = MockHomeBloc();
    currencyCubit = MockCurrencyCubit();
    networkCubit = MockNetworkCubit();
    tableCubit = MockTableCubit();

    // Default currency state: IDR selected, no exchange rates → falls back to IDR display
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
    expect(find.text('Grand Total'), findsOneWidget);
    expect(find.text('Proceed to Payment'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('displays correct total', (tester) async {
    when(() => homeBloc.state).thenReturn(
      HomeState(cartItems: [CartItem(product: product, quantity: 2)]),
    );

    await tester.pumpWidget(buildTestableWidget());

    // Total should be 15000 * 2 = 30000, displayed as IDR 30.000
    expect(find.textContaining('30.000'), findsAtLeastNWidgets(1));
  });
}
