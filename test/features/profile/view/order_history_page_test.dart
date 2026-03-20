import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/features/profile/view/order_history_page.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockNetworkCubit extends MockCubit<NetworkState>
    implements NetworkCubit {}

void main() {
  late MockOrderRepository orderRepo;
  late MockCurrencyCubit currencyCubit;
  late MockNetworkCubit networkCubit;

  setUp(() {
    orderRepo = MockOrderRepository();
    currencyCubit = MockCurrencyCubit();
    networkCubit = MockNetworkCubit();

    when(() => orderRepo.getOrders(any())).thenAnswer((_) async => []);
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

  Widget buildWidget() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OrderRepository>.value(value: orderRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CurrencyCubit>.value(value: currencyCubit),
          BlocProvider<NetworkCubit>.value(value: networkCubit),
        ],
        child: const MaterialApp(home: OrderHistoryPage()),
      ),
    );
  }

  testWidgets('OrderHistoryPage renders correctly', (tester) async {
    await tester.pumpWidget(buildWidget());
    // Resolve the FutureBuilder
    await tester.pumpAndSettle();

    expect(find.text('Order History'), findsOneWidget);
    // No orders → empty state message
    expect(find.text('No orders yet'), findsOneWidget);
  });

  testWidgets('OrderHistoryPage respects max width constraint', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final constrainedBoxFinder = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox && widget.constraints.maxWidth == 600.0,
    );
    expect(constrainedBoxFinder, findsAtLeastNWidgets(1));

    addTearDown(tester.view.resetPhysicalSize);
  });
}
