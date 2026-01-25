import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/widgets/macos_title_bar.dart';
import '../features/home/view/home_page.dart';
import '../features/home/view/order_confirmation_page.dart';
import '../features/home/view/payment_successful_page.dart';
import '../features/home/view/select_payment_method_page.dart';
import '../features/profile/view/help_support_page.dart';
import '../features/profile/view/order_history_page.dart';
import '../features/profile/view/payment_methods_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/profile/view/settings_page.dart';
import '../features/profile/view/theme_settings_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MacOSTitleBar(child: HomePage()),
      ),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) => const OrderConfirmationPage(),
      ),
      GoRoute(
        path: '/select-payment-method',
        builder: (context, state) => const SelectPaymentMethodPage(),
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
            path: 'payments',
            builder: (context, state) => const PaymentMethodsPage(),
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
        ],
      ),
    ],
  );
}
