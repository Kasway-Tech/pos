import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/table/table_state.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/data/models/table_item.dart';
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

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _product = Product(
  id: '1',
  name: 'Test Product',
  price: 10000,
  imageUrl: '',
);

const _freeTable = TableItem(
  id: 'table-1',
  label: '1',
  seats: 4,
  x: 100,
  y: 100,
  isOccupied: false,
);

// ---------------------------------------------------------------------------
// Router helpers for _proceedToPayment tests
//
// _proceedToPayment uses context.push('/table-selection') and
// context.push('/kaspa-payment'). A GoRouter with stub routes for those
// paths allows us to observe navigation without rendering the real pages.
// ---------------------------------------------------------------------------

/// A stub destination that records the route name it was shown for.
class _StubPage extends StatelessWidget {
  const _StubPage({required this.routeName});
  final String routeName;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Text('stub:$routeName'));
}

/// Builds a GoRouter with the providers needed by OrderSideView wired in so
/// that context.push works even from within the ShellRoute.
GoRouter _buildRouter({
  required MockHomeBloc homeBloc,
  required MockCurrencyCubit currencyCubit,
  required MockNetworkCubit networkCubit,
  required MockTableCubit tableCubit,
  /// Optional callback invoked when /table-selection is pushed, used to
  /// simulate the user selecting (or not selecting) a table before popping.
  void Function(MockTableCubit)? onTableSelectionPushed,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>.value(value: homeBloc),
            BlocProvider<CurrencyCubit>.value(value: currencyCubit),
            BlocProvider<NetworkCubit>.value(value: networkCubit),
            BlocProvider<TableCubit>.value(value: tableCubit),
          ],
          child: const Scaffold(body: OrderSideView(showAppBar: true)),
        ),
      ),
      GoRoute(
        path: '/table-selection',
        builder: (context, state) {
          // Simulate the page: invoke the callback (which may change cubit
          // state to represent a selection), then immediately return a stub.
          onTableSelectionPushed?.call(tableCubit);
          return const _StubPage(routeName: 'table-selection');
        },
      ),
      GoRoute(
        path: '/kaspa-payment',
        builder: (context, state) =>
            const _StubPage(routeName: 'kaspa-payment'),
      ),
    ],
  );
}

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
    when(() => tableCubit.freeTable(any())).thenReturn(null);
    when(() => tableCubit.clearSelection()).thenReturn(null);
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

  // ── Smoke tests ────────────────────────────────────────────────────────────

  testWidgets('OrderSideView renders empty state correctly', (tester) async {
    when(() => homeBloc.state).thenReturn(const HomeState());

    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Order List'), findsOneWidget);
    // Proceed to Payment button visible because screenWidth >= 800 in test environment
    expect(find.text('Proceed to Payment'), findsOneWidget);
  });

  testWidgets('OrderSideView renders cart items', (tester) async {
    final cartItem = CartItem(product: _product, quantity: 1);

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

  // ── _proceedToPayment — table layout disabled ──────────────────────────────

  group('_proceedToPayment — table layout disabled', () {
    testWidgets(
      'navigates directly to /kaspa-payment when table layout is disabled',
      (tester) async {
        final cartItem = CartItem(product: _product, quantity: 1);
        when(() => homeBloc.state)
            .thenReturn(HomeState(cartItems: [cartItem]));
        // Table layout disabled (default)
        when(() => tableCubit.state).thenReturn(const TableState());

        final router = _buildRouter(
          homeBloc: homeBloc,
          currencyCubit: currencyCubit,
          networkCubit: networkCubit,
          tableCubit: tableCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        // Should land on the kaspa-payment stub, NOT table-selection
        expect(find.text('stub:kaspa-payment'), findsOneWidget);
        expect(find.text('stub:table-selection'), findsNothing);

        // freeTable must NOT be called when table layout is disabled
        verifyNever(() => tableCubit.freeTable(any()));
      },
    );
  });

  // ── _proceedToPayment — table layout enabled ───────────────────────────────

  group('_proceedToPayment — table layout enabled', () {
    setUp(() {
      // Cart must be non-empty to enable the button
      final cartItem = CartItem(product: _product, quantity: 1);
      when(() => homeBloc.state)
          .thenReturn(HomeState(cartItems: [cartItem]));
    });

    testWidgets(
      'frees existing selection before pushing /table-selection',
      (tester) async {
        // Existing stale selection
        when(() => tableCubit.state).thenReturn(
          const TableState(
            enabled: true,
            tables: [_freeTable],
            selectedTableId: 'table-1',
          ),
        );

        final router = _buildRouter(
          homeBloc: homeBloc,
          currencyCubit: currencyCubit,
          networkCubit: networkCubit,
          tableCubit: tableCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        verify(() => tableCubit.freeTable('table-1')).called(1);
      },
    );

    testWidgets(
      'pushes /table-selection when table layout is enabled',
      (tester) async {
        when(() => tableCubit.state).thenReturn(
          const TableState(enabled: true, tables: [_freeTable]),
        );

        final router = _buildRouter(
          homeBloc: homeBloc,
          currencyCubit: currencyCubit,
          networkCubit: networkCubit,
          tableCubit: tableCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        expect(find.text('stub:table-selection'), findsOneWidget);
      },
    );

    testWidgets(
      'pushes /kaspa-payment after returning from /table-selection with a table selected',
      (tester) async {
        // Start: no table selected
        when(() => tableCubit.state).thenReturn(
          const TableState(enabled: true, tables: [_freeTable]),
        );

        // When table-selection is pushed, simulate the user selecting a table:
        // update the mock state so selectedTableId is now set.
        final router = _buildRouter(
          homeBloc: homeBloc,
          currencyCubit: currencyCubit,
          networkCubit: networkCubit,
          tableCubit: tableCubit,
          onTableSelectionPushed: (cubit) {
            when(() => cubit.state).thenReturn(
              const TableState(
                enabled: true,
                tables: [_freeTable],
                selectedTableId: 'table-1',
              ),
            );
          },
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        // The stub table-selection page is shown; now pop back (simulating
        // user selecting a table and the page calling context.pop()).
        final NavigatorState navigator = tester.state(find.byType(Navigator));
        navigator.pop();
        await tester.pumpAndSettle();

        // After returning with a selected table, /kaspa-payment must be pushed
        expect(find.text('stub:kaspa-payment'), findsOneWidget);
      },
    );

    testWidgets(
      'does NOT push /kaspa-payment after returning from /table-selection without selecting',
      (tester) async {
        // State: table layout enabled but no table selected (and remains so
        // after returning from table-selection — user cancelled)
        when(() => tableCubit.state).thenReturn(
          const TableState(enabled: true, tables: [_freeTable]),
        );

        final router = _buildRouter(
          homeBloc: homeBloc,
          currencyCubit: currencyCubit,
          networkCubit: networkCubit,
          tableCubit: tableCubit,
          // onTableSelectionPushed is null → state stays with no selection
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        // Pop /table-selection without selecting (selectedTableId remains null)
        final NavigatorState navigator = tester.state(find.byType(Navigator));
        navigator.pop();
        await tester.pumpAndSettle();

        // Should NOT have navigated to kaspa-payment
        expect(find.text('stub:kaspa-payment'), findsNothing);
      },
    );

    testWidgets(
      'calls freeTable(null) without error when no stale selection exists',
      (tester) async {
        when(() => tableCubit.state).thenReturn(
          const TableState(enabled: true, tables: [_freeTable]),
        );

        final router = _buildRouter(
          homeBloc: homeBloc,
          currencyCubit: currencyCubit,
          networkCubit: networkCubit,
          tableCubit: tableCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Proceed to Payment'));
        await tester.pumpAndSettle();

        // freeTable(null) must be called (selectedTableId was null)
        verify(() => tableCubit.freeTable(null)).called(1);
      },
    );
  });
}
