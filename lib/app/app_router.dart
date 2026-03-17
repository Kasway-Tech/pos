import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/view/home_page.dart';
import '../features/home/view/order_confirmation_page.dart';
import '../features/home/view/payment_successful_page.dart';
import '../features/profile/view/help_support_page.dart';
import '../features/profile/view/order_history_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/profile/view/settings_page.dart';
import '../features/profile/view/currency_settings_page.dart';
import '../features/profile/view/theme_settings_page.dart';

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
      GoRoute(
        path: '/payment-success',
        builder: (context, state) => const PaymentSuccessfulPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'orders',
            builder: (context, state) => const OrderHistoryPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'help',
            builder: (context, state) => const HelpSupportPage(),
          ),
          GoRoute(
            path: 'theme',
            builder: (context, state) => const ThemeSettingsPage(),
          ),
          GoRoute(
            path: 'currency',
            builder: (context, state) => const CurrencySettingsPage(),
          ),
        ],
      ),
    ],
  );
}
