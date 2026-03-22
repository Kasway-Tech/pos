import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/kaspa_resolver_service.dart';
import '../constants/preference_keys.dart';
import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit({KaspaResolverService? resolverService})
      : _resolver = resolverService ?? KaspaResolverService(),
        super(const NetworkState()) {
    _load();
  }

  final KaspaResolverService _resolver;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final networkStr = prefs.getString(PreferenceKeys.kaspaNetwork);
    final network =
        networkStr == 'testnet10' ? KaspaNetwork.testnet10 : KaspaNetwork.mainnet;

    // Read from the new custom URL keys.
    String? mainnetCustomUrl =
        prefs.getString(PreferenceKeys.kaspaMainnetCustomUrl);
    String? testnet10CustomUrl =
        prefs.getString(PreferenceKeys.kaspaTestnet10CustomUrl);

    // One-time migration: if old key has a non-default value, promote it.
    if (mainnetCustomUrl == null) {
      final oldMainnet = prefs.getString(PreferenceKeys.kaspaMainnetUrl);
      if (oldMainnet != null &&
          oldMainnet != NetworkState.fallbackMainnetUrl) {
        mainnetCustomUrl = oldMainnet;
        await prefs.setString(
            PreferenceKeys.kaspaMainnetCustomUrl, oldMainnet);
      }
    }
    if (testnet10CustomUrl == null) {
      final oldTestnet = prefs.getString(PreferenceKeys.kaspaTestnet10Url);
      if (oldTestnet != null &&
          oldTestnet != NetworkState.fallbackTestnet10Url) {
        testnet10CustomUrl = oldTestnet;
        await prefs.setString(
            PreferenceKeys.kaspaTestnet10CustomUrl, oldTestnet);
      }
    }

    if (isClosed) return;
    emit(NetworkState(
      network: network,
      mainnetCustomUrl: mainnetCustomUrl,
      testnet10CustomUrl: testnet10CustomUrl,
    ));

    // Resolve in the background; activeUrl falls back to hardcoded default
    // until resolution completes.
    unawaited(_resolveAll());
  }

  Future<void> _resolveAll() async {
    final results = await Future.wait([
      _resolver.resolve(KaspaNetwork.mainnet),
      _resolver.resolve(KaspaNetwork.testnet10),
    ]);
    if (isClosed) return;
    final resolvedMainnet = results[0];
    final resolvedTestnet = results[1];
    if (resolvedMainnet != state.resolvedMainnetUrl ||
        resolvedTestnet != state.resolvedTestnet10Url) {
      emit(state.copyWith(
        resolvedMainnetUrl: resolvedMainnet,
        resolvedTestnet10Url: resolvedTestnet,
      ));
    }
  }

  Future<void> setNetwork(KaspaNetwork network) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PreferenceKeys.kaspaNetwork,
      network == KaspaNetwork.mainnet ? 'mainnet' : 'testnet10',
    );
    emit(state.copyWith(network: network));
  }

  Future<void> setCustomMainnetUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.kaspaMainnetCustomUrl, url);
    emit(state.copyWith(mainnetCustomUrl: url));
  }

  Future<void> setCustomTestnet10Url(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.kaspaTestnet10CustomUrl, url);
    emit(state.copyWith(testnet10CustomUrl: url));
  }

  Future<void> resetToAuto(KaspaNetwork network) async {
    final prefs = await SharedPreferences.getInstance();
    if (network == KaspaNetwork.mainnet) {
      await prefs.remove(PreferenceKeys.kaspaMainnetCustomUrl);
      emit(state.copyWith(mainnetCustomUrl: null));
    } else {
      await prefs.remove(PreferenceKeys.kaspaTestnet10CustomUrl);
      emit(state.copyWith(testnet10CustomUrl: null));
    }
    unawaited(_resolveAll());
  }

  /// Re-runs the resolver in the background. No-op when a custom URL is set
  /// for the active network (custom mode does not use the resolver).
  Future<void> triggerResolve() async {
    if (!state.isAutoMode) return;
    unawaited(_resolveAll());
  }
}
