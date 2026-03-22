import 'package:equatable/equatable.dart';

enum KaspaNetwork { mainnet, testnet10 }

class NetworkState extends Equatable {
  static const fallbackMainnetUrl =
      'wss://rose.kaspa.green/kaspa/mainnet/wrpc/json';
  static const fallbackTestnet10Url =
      'wss://electron-10.kaspa.stream/kaspa/testnet-10/wrpc/json';

  // Aliases kept for any code that still references the old constant names.
  static const defaultMainnetUrl = fallbackMainnetUrl;
  static const defaultTestnet10Url = fallbackTestnet10Url;

  const NetworkState({
    this.network = KaspaNetwork.mainnet,
    this.mainnetCustomUrl,
    this.testnet10CustomUrl,
    this.resolvedMainnetUrl,
    this.resolvedTestnet10Url,
  });

  final KaspaNetwork network;

  /// Explicitly saved custom URL. Non-null means the user has overridden the
  /// resolver for this network.
  final String? mainnetCustomUrl;
  final String? testnet10CustomUrl;

  /// URL last discovered by [KaspaResolverService]. Null until the first
  /// successful resolution.
  final String? resolvedMainnetUrl;
  final String? resolvedTestnet10Url;

  /// The URL that wRPC clients should connect to.
  /// Priority: custom > resolved > hardcoded fallback.
  String get activeUrl => network == KaspaNetwork.mainnet
      ? (mainnetCustomUrl ?? resolvedMainnetUrl ?? fallbackMainnetUrl)
      : (testnet10CustomUrl ?? resolvedTestnet10Url ?? fallbackTestnet10Url);

  /// `true` when no custom URL has been saved for the active network, meaning
  /// the resolver (or fallback) chooses the node automatically.
  bool get isAutoMode => network == KaspaNetwork.mainnet
      ? mainnetCustomUrl == null
      : testnet10CustomUrl == null;

  /// The resolved URL for the active network (null if not yet resolved or in
  /// custom-URL mode).
  String? get activeResolvedUrl => network == KaspaNetwork.mainnet
      ? resolvedMainnetUrl
      : resolvedTestnet10Url;

  String get networkLabel =>
      network == KaspaNetwork.mainnet ? 'Mainnet' : 'Testnet-10';

  String get kasSymbol => network == KaspaNetwork.mainnet ? 'KAS' : 'TKAS';

  String get addressHrp =>
      network == KaspaNetwork.mainnet ? 'kaspa' : 'kaspatest';

  String get activeBorshUrl => activeUrl.replaceFirst('/json', '/borsh');

  String get explorerBaseUrl => network == KaspaNetwork.mainnet
      ? 'https://kaspa.stream/transactions/'
      : 'https://tn10.kaspa.stream/transactions/';

  String get explorerAddressBaseUrl => network == KaspaNetwork.mainnet
      ? 'https://kaspa.stream/addresses/'
      : 'https://tn10.kaspa.stream/addresses/';

  // Sentinel used to distinguish "pass null explicitly" from "not provided".
  static const _sentinel = Object();

  NetworkState copyWith({
    KaspaNetwork? network,
    Object? mainnetCustomUrl = _sentinel,
    Object? testnet10CustomUrl = _sentinel,
    Object? resolvedMainnetUrl = _sentinel,
    Object? resolvedTestnet10Url = _sentinel,
  }) =>
      NetworkState(
        network: network ?? this.network,
        mainnetCustomUrl: mainnetCustomUrl == _sentinel
            ? this.mainnetCustomUrl
            : mainnetCustomUrl as String?,
        testnet10CustomUrl: testnet10CustomUrl == _sentinel
            ? this.testnet10CustomUrl
            : testnet10CustomUrl as String?,
        resolvedMainnetUrl: resolvedMainnetUrl == _sentinel
            ? this.resolvedMainnetUrl
            : resolvedMainnetUrl as String?,
        resolvedTestnet10Url: resolvedTestnet10Url == _sentinel
            ? this.resolvedTestnet10Url
            : resolvedTestnet10Url as String?,
      );

  @override
  List<Object?> get props => [
        network,
        mainnetCustomUrl,
        testnet10CustomUrl,
        resolvedMainnetUrl,
        resolvedTestnet10Url,
      ];
}
