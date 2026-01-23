import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/view/home_page.dart';
import '../features/home/view/order_confirmation_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) => const OrderConfirmationPage(),
      ),
    ],
  );
}
