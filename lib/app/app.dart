import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/theme/theme_cubit.dart';
import 'package:kasway/app/theme/theme_state.dart';
import 'package:kasway/data/repositories/auth_repository.dart';
import 'package:kasway/data/repositories/branch_repository.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/data/repositories/transaction_repository.dart';
import 'package:kasway/features/auth/cubit/auth_cubit.dart';
import 'package:kasway/features/branch/cubit/branch_cubit.dart';

import '../features/home/bloc/home_bloc.dart';
import 'app_router.dart';
import 'theme.dart';
import 'util.dart';

class App extends StatelessWidget {
  const App({super.key, required this.scaffoldMessengerKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final textTheme = createTextTheme(context, "Inter", "Inter");
          final theme = MaterialTheme(textTheme);

          final screenWidth = MediaQuery.sizeOf(context).width;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (_) => AuthRepository()),
              RepositoryProvider(create: (_) => BranchRepository()),
              RepositoryProvider(create: (_) => ProductRepository()),
              RepositoryProvider(create: (_) => TransactionRepository()),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => AuthCubit(
                    authRepository: context.read<AuthRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => BranchCubit(
                    branchRepository: context.read<BranchRepository>(),
                    authRepository: context.read<AuthRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => HomeBloc(
                    productRepository: context.read<ProductRepository>(),
                    transactionRepository:
                        context.read<TransactionRepository>(),
                  ),
                ),
              ],
              child: Builder(
                builder: (context) => MaterialApp.router(
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  scrollBehavior: AppScrollBehavior(),
                  title: 'Kasway',
                  theme: theme.light(themeState.seedColor, isTablet),
                  darkTheme: theme.dark(themeState.seedColor, isTablet),
                  themeMode: themeState.themeMode,
                  routerConfig: AppRouter.router(context),
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
