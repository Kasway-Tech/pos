import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:kasway/features/auth/cubit/auth_cubit.dart';
import 'package:kasway/features/auth/cubit/auth_state.dart';
import 'package:kasway/features/auth/view/link_google_page.dart';
import 'package:kasway/features/auth/view/login_page.dart';
import 'package:kasway/features/branch/cubit/branch_cubit.dart';
import 'package:kasway/features/branch/view/branch_selection_page.dart';

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

  static GoRouter router(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final branchCubit = context.read<BranchCubit>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: _CombinedListenable([authCubit.stream, branchCubit.stream]),
      redirect: (ctx, state) {
        final authStatus = authCubit.state.status;
        final hasBranch = branchCubit.state.hasBranchSelected;
        final path = state.uri.path;

        if (authStatus == AuthStatus.initial) return null;

        final isAuthenticated = authStatus == AuthStatus.authenticated;
        final needsGoogleLink = authStatus == AuthStatus.needsGoogleLink;

        // Not signed in → login
        if (!isAuthenticated && !needsGoogleLink) {
          return path == '/login' ? null : '/login';
        }

        // Signed in via invitation but Google not linked yet → link Google
        if (needsGoogleLink) {
          return path == '/link-google' ? null : '/link-google';
        }

        // Authenticated but no branch selected
        if (!hasBranch) {
          return path == '/branch-select' ? null : '/branch-select';
        }

        // Fully authenticated — redirect away from auth pages
        const authPaths = ['/login', '/link-google', '/branch-select'];
        if (authPaths.contains(path)) return '/';

        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/link-google',
          builder: (context, state) => const LinkGooglePage(),
        ),
        GoRoute(
          path: '/branch-select',
          builder: (context, state) => const BranchSelectionPage(),
        ),
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
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
}

/// Combines multiple Bloc/Cubit streams into a single [Listenable]
/// so go_router can react to auth/branch state changes.
class _CombinedListenable extends ChangeNotifier {
  _CombinedListenable(List<Stream<dynamic>> streams) {
    for (final stream in streams) {
      _subscriptions.add(stream.listen((_) => notifyListeners()));
    }
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
