import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/view/widgets/additions_side_view.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockNetworkCubit extends MockCubit<NetworkState>
    implements NetworkCubit {}

/// Wraps [child] with the cubits that [PriceText] and [OrderSideView] require.
Widget _withProviders({
  required Widget child,
  required MockCurrencyCubit currencyCubit,
  required MockNetworkCubit networkCubit,
}) {
  return MaterialApp(
    home: Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<CurrencyCubit>.value(value: currencyCubit),
          BlocProvider<NetworkCubit>.value(value: networkCubit),
        ],
        child: child,
      ),
    ),
  );
}

void main() {
  late MockCurrencyCubit currencyCubit;
  late MockNetworkCubit networkCubit;

  setUp(() {
    currencyCubit = MockCurrencyCubit();
    networkCubit = MockNetworkCubit();

    // IDR display: no exchange-rate needed, formatPrice falls back to IDR directly
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
  });

  testWidgets('AdditionsSideView renders correctly', (tester) async {
    const addition = Addition(id: 'a1', name: 'Extra Cheese', price: 500);
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
      additions: [addition],
    );

    await tester.pumpWidget(
      _withProviders(
        currencyCubit: currencyCubit,
        networkCubit: networkCubit,
        child: AdditionsSideView(
          product: product,
          onConfirm: (_) {},
          onBack: () {},
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Extra Cheese'), findsOneWidget);
    expect(find.text('Add to Order'), findsOneWidget);
  });

  testWidgets('AdditionsSideView handles selection', (tester) async {
    const addition = Addition(id: 'a1', name: 'Extra Cheese', price: 500);
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
      additions: [addition],
    );

    List<Addition>? selectedAdditions;

    await tester.pumpWidget(
      _withProviders(
        currencyCubit: currencyCubit,
        networkCubit: networkCubit,
        child: AdditionsSideView(
          product: product,
          onConfirm: (additions) => selectedAdditions = additions,
          onBack: () {},
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
