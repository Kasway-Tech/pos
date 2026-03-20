import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/app/wallet/wallet_state.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/data/repositories/withdrawal_repository.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/profile/view/profile_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockWithdrawalRepository extends Mock implements WithdrawalRepository {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockNetworkCubit extends MockCubit<NetworkState>
    implements NetworkCubit {}

class MockWalletCubit extends MockCubit<WalletState> implements WalletCubit {}

Widget _wrap(
  Widget child, {
  required MockOrderRepository orderRepo,
  required MockWithdrawalRepository withdrawalRepo,
  required MockHomeBloc homeBloc,
  required MockCurrencyCubit currencyCubit,
  required MockNetworkCubit networkCubit,
  required MockWalletCubit walletCubit,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<OrderRepository>.value(value: orderRepo),
      RepositoryProvider<WithdrawalRepository>.value(value: withdrawalRepo),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(value: homeBloc),
        BlocProvider<CurrencyCubit>.value(value: currencyCubit),
        BlocProvider<NetworkCubit>.value(value: networkCubit),
        BlocProvider<WalletCubit>.value(value: walletCubit),
      ],
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  late MockOrderRepository orderRepo;
  late MockWithdrawalRepository withdrawalRepo;
  late MockHomeBloc homeBloc;
  late MockCurrencyCubit currencyCubit;
  late MockNetworkCubit networkCubit;
  late MockWalletCubit walletCubit;

  setUp(() {
    orderRepo = MockOrderRepository();
    withdrawalRepo = MockWithdrawalRepository();
    homeBloc = MockHomeBloc();
    currencyCubit = MockCurrencyCubit();
    networkCubit = MockNetworkCubit();
    walletCubit = MockWalletCubit();

    when(() => orderRepo.getTodayRevenue(any())).thenAnswer((_) async => 0.0);
    when(() => homeBloc.state).thenReturn(const HomeState());
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
    when(() => walletCubit.state).thenReturn(
      const WalletState(addressReady: true),
    );

    SharedPreferences.setMockInitialValues({});
  });

  Widget buildWidget() => _wrap(
        const ProfilePage(),
        orderRepo: orderRepo,
        withdrawalRepo: withdrawalRepo,
        homeBloc: homeBloc,
        currencyCubit: currencyCubit,
        networkCubit: networkCubit,
        walletCubit: walletCubit,
      );

  testWidgets('ProfilePage renders correctly', (tester) async {
    await tester.pumpWidget(buildWidget());

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('ProfilePage has max width constraint logic', (tester) async {
    // Use a narrow screen (< 720px wide) to trigger the narrow layout,
    // which wraps its content in ConstrainedBox(maxWidth: 600).
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(buildWidget());

    final constrainedBoxFinder = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox && widget.constraints.maxWidth == 600.0,
    );

    expect(constrainedBoxFinder, findsAtLeastNWidgets(1));

    addTearDown(tester.view.resetPhysicalSize);
  });
}
