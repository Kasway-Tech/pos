import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/widgets/product_card.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockNetworkCubit extends MockCubit<NetworkState>
    implements NetworkCubit {}

void main() {
  late MockHomeBloc homeBloc;
  late MockCurrencyCubit currencyCubit;
  late MockNetworkCubit networkCubit;

  setUp(() {
    homeBloc = MockHomeBloc();
    currencyCubit = MockCurrencyCubit();
    networkCubit = MockNetworkCubit();

    when(() => homeBloc.state).thenReturn(const HomeState());
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
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<CurrencyCubit>.value(value: currencyCubit),
          BlocProvider<NetworkCubit>.value(value: networkCubit),
        ],
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('ProductCard renders correctly', (tester) async {
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
    );

    await tester.pumpWidget(
      buildTestableWidget(
        ProductCard(product: product, onTap: () {}, onLongPress: () {}),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('IDR 10.000'), findsOneWidget);
  });
}
