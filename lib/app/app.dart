import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/theme/theme_cubit.dart';
import 'package:kasway/app/theme/theme_state.dart';
import 'package:kasway/data/repositories/product_repository.dart';

import '../features/home/bloc/home_bloc.dart';
import '../features/home/bloc/home_event.dart';
import 'app_router.dart';
import 'theme.dart';
import 'util.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => CurrencyCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final textTheme = createTextTheme(context, "Inter", "Inter");
          final theme = MaterialTheme(textTheme);

          final screenWidth = MediaQuery.sizeOf(context).width;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (context) => ProductRepository()),
            ],
            child: BlocProvider(
              create: (context) =>
                  HomeBloc(productRepository: context.read<ProductRepository>())
                    ..add(HomeStarted()),
              child: MaterialApp.router(
                scrollBehavior: AppScrollBehavior(),
                title: 'Kasway',
                theme: theme.light(themeState.seedColor, isTablet),
                darkTheme: theme.dark(themeState.seedColor, isTablet),
                themeMode: themeState.themeMode,
                routerConfig: AppRouter.router,
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

  // @override
  // ScrollPhysics getScrollPhysics(BuildContext context) {
  //   return const BouncingScrollPhysics();
  // }
}
