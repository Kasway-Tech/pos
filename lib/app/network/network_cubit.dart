import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(const NetworkState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final networkStr = prefs.getString(PreferenceKeys.kaspaNetwork);
    final mainnetUrl =
        prefs.getString(PreferenceKeys.kaspaMainnetUrl) ?? NetworkState.defaultMainnetUrl;
    final testnet10Url =
        prefs.getString(PreferenceKeys.kaspaTestnet10Url) ?? NetworkState.defaultTestnet10Url;
    final network =
        networkStr == 'testnet10' ? KaspaNetwork.testnet10 : KaspaNetwork.mainnet;
    emit(NetworkState(
      network: network,
      mainnetUrl: mainnetUrl,
      testnet10Url: testnet10Url,
    ));
  }

  Future<void> setNetwork(KaspaNetwork network) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PreferenceKeys.kaspaNetwork,
      network == KaspaNetwork.mainnet ? 'mainnet' : 'testnet10',
    );
    emit(state.copyWith(network: network));
  }

  Future<void> setMainnetUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.kaspaMainnetUrl, url);
    emit(state.copyWith(mainnetUrl: url));
  }

  Future<void> setTestnet10Url(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.kaspaTestnet10Url, url);
    emit(state.copyWith(testnet10Url: url));
  }
}
