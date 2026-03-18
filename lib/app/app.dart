import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kasway/l10n/app_localizations.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/locale/locale_cubit.dart';
import 'package:kasway/app/locale/locale_state.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/theme/theme_cubit.dart';
import 'package:kasway/app/theme/theme_state.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/data/repositories/withdrawal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/bloc/home_bloc.dart';
import '../features/home/bloc/home_event.dart';
import 'app_router.dart';
import 'theme.dart';
import 'util.dart';

class App extends StatefulWidget {
  const App({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ValueNotifier<bool> _onboardingNotifier;

  @override
  void initState() {
    super.initState();
    _onboardingNotifier = ValueNotifier(
      widget.prefs.getBool('onboarding_complete') ?? false,
    );
  }

  @override
  void dispose() {
    _onboardingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => CurrencyCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => NetworkCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final localeState = context.watch<LocaleCubit>().state;
          final textTheme = createTextTheme(context, "Inter", "Inter");
          final theme = MaterialTheme(textTheme);

          final screenWidth = MediaQuery.sizeOf(context).width;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (_) => ProductRepository()),
              RepositoryProvider(create: (_) => OrderRepository()),
              RepositoryProvider(create: (_) => WithdrawalRepository()),
            ],
            child: BlocProvider(
              create: (context) => HomeBloc(
                productRepository: context.read<ProductRepository>(),
                orderRepository: context.read<OrderRepository>(),
              )..add(HomeStarted()),
              child: MaterialApp.router(
                scrollBehavior: AppScrollBehavior(),
                title: 'Kasway',
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: localeState.locale,
                supportedLocales: LocaleState.supportedLanguages
                    .map((l) => l.locale)
                    .toList(),
                theme: theme.light(themeState.seedColor, isTablet),
                darkTheme: theme.dark(themeState.seedColor, isTablet),
                themeMode: themeState.themeMode,
                routerConfig: AppRouter.router(
                  widget.prefs,
                  _onboardingNotifier,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
