import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:kasway/app/network/node_status_cubit.dart';
import 'package:kasway/app/network/node_status_state.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/app/wallet/wallet_state.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _ratesTimedOut = false;
  Timer? _ratesTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _prefetchCurrencyFlags();
    // After 3 seconds, navigate regardless of exchange rate status (handles offline).
    _ratesTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _ratesTimedOut = true;
        _maybeNavigate();
      }
    });
    // Check immediately in case everything is already ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeNavigate());
  }

  // Warm up the asset bundle cache for all currency flag .si files used by
  // country_flags so the currency picker page opens instantly.
  void _prefetchCurrencyFlags() {
    const flagCodes = [
      'ae', 'au', 'br', 'ca', 'ch', 'cn', 'eu', 'gb',
      'hk', 'id', 'in', 'jp', 'kr', 'mx', 'my', 'ng',
      'nz', 'ph', 'pk', 'sa', 'sg', 'th', 'us', 'vn', 'za',
    ];
    for (final code in flagCodes) {
      rootBundle.load('packages/country_flags/res/si/$code.si');
    }
  }

  @override
  void dispose() {
    _ratesTimer?.cancel();
    super.dispose();
  }

  bool _ratesReady(CurrencyState currencyState) {
    return _ratesTimedOut ||
        !currencyState.dynamicPricing ||
        currencyState.exchangeRates.isNotEmpty;
  }

  void _maybeNavigate() {
    if (_navigated || !mounted) return;
    final homeState = context.read<HomeBloc>().state;
    final walletState = context.read<WalletCubit>().state;
    final currencyState = context.read<CurrencyCubit>().state;

    final nodeState = context.read<NodeStatusCubit>().state;

    final homeReady =
        homeState.status != HomeStatus.loading &&
        homeState.status != HomeStatus.initial;
    final walletReady = walletState.addressReady;
    final ratesReady = _ratesReady(currencyState);
    final nodeReady = _ratesTimedOut || nodeState.connected;

    if (homeReady && walletReady && ratesReady && nodeReady) {
      _navigated = true;
      final done = widget.prefs.getBool(PreferenceKeys.onboardingComplete) ?? false;
      context.go(done ? '/' : '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, _) => _maybeNavigate(),
        ),
        BlocListener<WalletCubit, WalletState>(
          listenWhen: (prev, curr) => prev.addressReady != curr.addressReady,
          listener: (context, _) => _maybeNavigate(),
        ),
        BlocListener<CurrencyCubit, CurrencyState>(
          listenWhen: (prev, curr) =>
              prev.exchangeRates != curr.exchangeRates ||
              prev.isLoading != curr.isLoading,
          listener: (context, _) => _maybeNavigate(),
        ),
        BlocListener<NodeStatusCubit, NodeStatusState>(
          listenWhen: (prev, curr) => prev.connected != curr.connected,
          listener: (context, _) => _maybeNavigate(),
        ),
      ],
      child: Scaffold(
        body: Center(
          child: SvgPicture.asset('assets/svg/brand_icon.svg', width: 120),
        ),
      ),
    );
  }
}
