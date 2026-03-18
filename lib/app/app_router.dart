import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/view/auth_page.dart';
import '../features/auth/view/eula_page.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/seed_phrase_page.dart';
import '../features/home/view/home_page.dart';
import '../features/home/view/order_confirmation_page.dart';
import '../features/home/view/payment_successful_page.dart';
import '../features/onboarding/view/onboarding_page.dart';
import '../features/profile/view/help_support_page.dart';
import '../features/profile/view/order_history_page.dart';
import '../features/profile/view/profile_page.dart';
import '../features/profile/view/settings_page.dart';
import '../features/profile/view/currency_settings_page.dart';
import '../features/profile/view/theme_settings_page.dart';
import '../features/items/view/item_management_page.dart';
import '../features/profile/view/data_transfer_page.dart';
import '../features/profile/view/withdrawal_history_page.dart';
import '../features/auth/view/onboarding_currency_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(
    SharedPreferences prefs,
    ValueNotifier<bool> onboardingNotifier,
  ) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/auth',
      refreshListenable: onboardingNotifier,
      redirect: kDebugMode
          ? null
          : (context, state) {
              final done = prefs.getBool('onboarding_complete') ?? false;
              final loc = state.matchedLocation;
              if (!done &&
                  !loc.startsWith('/auth') &&
                  !loc.startsWith('/onboarding')) {
                return '/auth';
              }
              if (done &&
                  (loc.startsWith('/auth') || loc.startsWith('/onboarding'))) {
                return '/';
              }
              return null;
            },
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
            GoRoute(
              path: 'items',
              builder: (context, state) => const ItemManagementPage(),
            ),
            GoRoute(
              path: 'data-transfer',
              builder: (context, state) => const DataTransferPage(),
            ),
            GoRoute(
              path: 'withdrawals',
              builder: (context, state) => const WithdrawalHistoryPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthPage(),
          routes: [
            GoRoute(
              path: 'eula',
              builder: (context, state) => const EulaPage(),
            ),
            GoRoute(
              path: 'seed-phrase',
              builder: (context, state) => const SeedPhrasePage(),
            ),
            GoRoute(
              path: 'currency',
              builder: (context, state) => const OnboardingCurrencyPage(),
            ),
            GoRoute(
              path: 'login',
              builder: (context, state) => LoginPage(
                prefs: prefs,
                onboardingNotifier: onboardingNotifier,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => OnboardingPage(
            prefs: prefs,
            onboardingNotifier: onboardingNotifier,
          ),
        ),
      ],
    );
  }
}
