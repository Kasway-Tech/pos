import 'dart:ui';

import 'package:atomikpos/app/theme/theme_cubit.dart';
import 'package:atomikpos/app/theme/theme_state.dart';
import 'package:atomikpos/data/repositories/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/home/bloc/home_bloc.dart';
import '../features/home/bloc/home_event.dart';
import 'app_router.dart';
import 'theme.dart';
import 'util.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final brightness = View.of(
            context,
          ).platformDispatcher.platformBrightness;

          TextTheme textTheme = createTextTheme(
            context,
            "Inter",
            "Plus Jakarta Sans",
          );

          MaterialTheme theme = MaterialTheme(textTheme);

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
                title: 'Atomik POS',
                theme: brightness == Brightness.light
                    ? theme.light(themeState.seedColor)
                    : theme.dark(themeState.seedColor),
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
