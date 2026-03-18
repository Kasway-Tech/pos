import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(const NetworkState()) {
    _load();
  }

  static const _kNetworkKey = 'kaspa_network';
  static const _kMainnetUrlKey = 'kaspa_mainnet_url';
  static const _kTestnet10UrlKey = 'kaspa_testnet10_url';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final networkStr = prefs.getString(_kNetworkKey);
    final mainnetUrl =
        prefs.getString(_kMainnetUrlKey) ?? NetworkState.defaultMainnetUrl;
    final testnet10Url =
        prefs.getString(_kTestnet10UrlKey) ?? NetworkState.defaultTestnet10Url;
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
      _kNetworkKey,
      network == KaspaNetwork.mainnet ? 'mainnet' : 'testnet10',
    );
    emit(state.copyWith(network: network));
  }

  Future<void> setMainnetUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMainnetUrlKey, url);
    emit(state.copyWith(mainnetUrl: url));
  }

  Future<void> setTestnet10Url(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTestnet10UrlKey, url);
    emit(state.copyWith(testnet10Url: url));
  }
}
