import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/locale/locale_cubit.dart';
import 'package:kasway/app/locale/locale_state.dart';
import 'package:kasway/features/profile/view/settings_page.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockLocaleCubit extends MockCubit<LocaleState> implements LocaleCubit {}

void main() {
  late MockCurrencyCubit currencyCubit;
  late MockLocaleCubit localeCubit;

  setUp(() {
    currencyCubit = MockCurrencyCubit();
    localeCubit = MockLocaleCubit();

    when(() => currencyCubit.state).thenReturn(
      const CurrencyState(
        selectedCurrency: Currency(
          code: 'IDR',
          name: 'Indonesian Rupiah',
          flag: '🇮🇩',
        ),
      ),
    );
    when(() => localeCubit.state).thenReturn(const LocaleState());
  });

  Widget buildWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrencyCubit>.value(value: currencyCubit),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
      ],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  testWidgets('SettingsPage renders correctly', (tester) async {
    await tester.pumpWidget(buildWidget());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Display Currency'), findsOneWidget);
  });

  testWidgets('SettingsPage respects max width constraint', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
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
