import 'package:equatable/equatable.dart';

enum KaspaNetwork { mainnet, testnet10 }

class NetworkState extends Equatable {
  static const defaultMainnetUrl =
      'wss://rose.kaspa.green/kaspa/mainnet/wrpc/json';
  static const defaultTestnet10Url =
      'wss://electron-10.kaspa.stream/kaspa/testnet-10/wrpc/json';

  const NetworkState({
    this.network = KaspaNetwork.mainnet,
    this.mainnetUrl = defaultMainnetUrl,
    this.testnet10Url = defaultTestnet10Url,
  });

  final KaspaNetwork network;
  final String mainnetUrl;
  final String testnet10Url;

  String get activeUrl =>
      network == KaspaNetwork.mainnet ? mainnetUrl : testnet10Url;

  String get networkLabel =>
      network == KaspaNetwork.mainnet ? 'Mainnet' : 'Testnet-10';

  String get kasSymbol => network == KaspaNetwork.mainnet ? 'KAS' : 'TKAS';

  NetworkState copyWith({
    KaspaNetwork? network,
    String? mainnetUrl,
    String? testnet10Url,
  }) => NetworkState(
    network: network ?? this.network,
    mainnetUrl: mainnetUrl ?? this.mainnetUrl,
    testnet10Url: testnet10Url ?? this.testnet10Url,
  );

  @override
  List<Object?> get props => [network, mainnetUrl, testnet10Url];
}
