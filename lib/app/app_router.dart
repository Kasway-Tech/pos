import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/counter/view/counter_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const CounterPage()),
    ],
  );
}
