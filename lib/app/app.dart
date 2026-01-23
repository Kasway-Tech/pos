import 'dart:ui';

import 'package:atomikpos/app/app_theme.dart';
import 'package:atomikpos/data/repositories/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ProductRepository(),
      child: MaterialApp.router(
        scrollBehavior: AppScrollBehavior(),
        title: 'Atomik POS',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
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
