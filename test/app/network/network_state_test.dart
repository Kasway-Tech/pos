import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/network/network_state.dart';

void main() {
  group('KaspaNetwork', () {
    test('enum has mainnet and testnet10 values', () {
      expect(KaspaNetwork.values, contains(KaspaNetwork.mainnet));
      expect(KaspaNetwork.values, contains(KaspaNetwork.testnet10));
      expect(KaspaNetwork.values.length, 2);
    });
  });

  group('NetworkState', () {
    group('default values', () {
      test('defaults to mainnet', () {
        const state = NetworkState();
        expect(state.network, KaspaNetwork.mainnet);
      });

      test('default instance has null custom and resolved URLs', () {
        const state = NetworkState();
        expect(state.mainnetCustomUrl, isNull);
        expect(state.testnet10CustomUrl, isNull);
        expect(state.resolvedMainnetUrl, isNull);
        expect(state.resolvedTestnet10Url, isNull);
      });

      test('fallback constants are correct', () {
        expect(
          NetworkState.fallbackMainnetUrl,
          'wss://rose.kaspa.green/kaspa/mainnet/wrpc/json',
        );
        expect(
          NetworkState.fallbackTestnet10Url,
          'wss://electron-10.kaspa.stream/kaspa/testnet-10/wrpc/json',
        );
      });

      test('defaultMainnetUrl alias equals fallbackMainnetUrl', () {
        expect(
            NetworkState.defaultMainnetUrl, NetworkState.fallbackMainnetUrl);
      });
    });

    group('activeUrl priority', () {
      test('falls back to hardcoded URL when nothing is set', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.activeUrl, NetworkState.fallbackMainnetUrl);
      });

      test('uses resolved URL when no custom URL is set', () {
        const state = NetworkState(
          network: KaspaNetwork.mainnet,
          resolvedMainnetUrl: 'wss://resolved.node/mainnet/wrpc/json',
        );
        expect(state.activeUrl, 'wss://resolved.node/mainnet/wrpc/json');
      });

      test('prefers custom URL over resolved URL', () {
        const state = NetworkState(
          network: KaspaNetwork.mainnet,
          mainnetCustomUrl: 'wss://custom.example.com/wrpc/json',
          resolvedMainnetUrl: 'wss://resolved.node/mainnet/wrpc/json',
        );
        expect(state.activeUrl, 'wss://custom.example.com/wrpc/json');
      });

      test('returns testnet fallback when testnet has nothing set', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.activeUrl, NetworkState.fallbackTestnet10Url);
      });

      test('returns custom testnet10 URL when set', () {
        const customUrl =
            'wss://my-node.example.com/kaspa/testnet-10/wrpc/json';
        const state = NetworkState(
          network: KaspaNetwork.testnet10,
          testnet10CustomUrl: customUrl,
        );
        expect(state.activeUrl, customUrl);
      });
    });

    group('isAutoMode', () {
      test('is true when mainnet has no custom URL', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.isAutoMode, isTrue);
      });

      test('is false when mainnet has custom URL', () {
        const state = NetworkState(
          network: KaspaNetwork.mainnet,
          mainnetCustomUrl: 'wss://custom.example.com/',
        );
        expect(state.isAutoMode, isFalse);
      });

      test('is true when testnet10 has no custom URL', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.isAutoMode, isTrue);
      });

      test('is false when testnet10 has custom URL', () {
        const state = NetworkState(
          network: KaspaNetwork.testnet10,
          testnet10CustomUrl: 'wss://custom-tn.example.com/',
        );
        expect(state.isAutoMode, isFalse);
      });
    });

    group('activeResolvedUrl', () {
      test('returns resolvedMainnetUrl for mainnet', () {
        const state = NetworkState(
          network: KaspaNetwork.mainnet,
          resolvedMainnetUrl: 'wss://resolved.mainnet/',
        );
        expect(state.activeResolvedUrl, 'wss://resolved.mainnet/');
      });

      test('returns resolvedTestnet10Url for testnet10', () {
        const state = NetworkState(
          network: KaspaNetwork.testnet10,
          resolvedTestnet10Url: 'wss://resolved.testnet/',
        );
        expect(state.activeResolvedUrl, 'wss://resolved.testnet/');
      });

      test('returns null when not yet resolved', () {
        const state = NetworkState();
        expect(state.activeResolvedUrl, isNull);
      });
    });

    group('networkLabel', () {
      test('returns Mainnet for mainnet', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.networkLabel, 'Mainnet');
      });

      test('returns Testnet-10 for testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.networkLabel, 'Testnet-10');
      });
    });

    group('kasSymbol', () {
      test('returns KAS for mainnet', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.kasSymbol, 'KAS');
      });

      test('returns TKAS for testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.kasSymbol, 'TKAS');
      });
    });

    group('addressHrp', () {
      test('returns kaspa for mainnet', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.addressHrp, 'kaspa');
      });

      test('returns kaspatest for testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.addressHrp, 'kaspatest');
      });
    });

    group('activeBorshUrl', () {
      test('replaces /json with /borsh using fallback mainnet URL', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(
          state.activeBorshUrl,
          'wss://rose.kaspa.green/kaspa/mainnet/wrpc/borsh',
        );
      });

      test('replaces /json with /borsh using fallback testnet10 URL', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(
          state.activeBorshUrl,
          'wss://electron-10.kaspa.stream/kaspa/testnet-10/wrpc/borsh',
        );
      });

      test('replaces /json with /borsh for custom URL', () {
        const customUrl = 'wss://custom.node.com/kaspa/mainnet/wrpc/json';
        const state = NetworkState(
          network: KaspaNetwork.mainnet,
          mainnetCustomUrl: customUrl,
        );
        expect(
          state.activeBorshUrl,
          'wss://custom.node.com/kaspa/mainnet/wrpc/borsh',
        );
      });
    });

    group('explorerBaseUrl', () {
      test('returns mainnet explorer URL for mainnet', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.explorerBaseUrl, 'https://kaspa.stream/transactions/');
      });

      test('returns testnet explorer URL for testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.explorerBaseUrl,
            'https://tn10.kaspa.stream/transactions/');
      });
    });

    group('explorerAddressBaseUrl', () {
      test('returns mainnet address explorer URL for mainnet', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.explorerAddressBaseUrl,
            'https://kaspa.stream/addresses/');
      });

      test('returns testnet address explorer URL for testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.explorerAddressBaseUrl,
            'https://tn10.kaspa.stream/addresses/');
      });
    });

    group('copyWith', () {
      test('returns identical state when no overrides provided', () {
        const state = NetworkState();
        final copy = state.copyWith();
        expect(copy.network, state.network);
        expect(copy.mainnetCustomUrl, state.mainnetCustomUrl);
        expect(copy.testnet10CustomUrl, state.testnet10CustomUrl);
        expect(copy.resolvedMainnetUrl, state.resolvedMainnetUrl);
        expect(copy.resolvedTestnet10Url, state.resolvedTestnet10Url);
      });

      test('overrides network', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        final copy = state.copyWith(network: KaspaNetwork.testnet10);
        expect(copy.network, KaspaNetwork.testnet10);
      });

      test('overrides mainnetCustomUrl', () {
        const newUrl = 'wss://new-node.example.com/kaspa/mainnet/wrpc/json';
        const state = NetworkState();
        final copy = state.copyWith(mainnetCustomUrl: newUrl);
        expect(copy.mainnetCustomUrl, newUrl);
        expect(copy.network, state.network);
      });

      test('overrides testnet10CustomUrl', () {
        const newUrl =
            'wss://new-node.example.com/kaspa/testnet-10/wrpc/json';
        const state = NetworkState();
        final copy = state.copyWith(testnet10CustomUrl: newUrl);
        expect(copy.testnet10CustomUrl, newUrl);
        expect(copy.network, state.network);
      });

      test('overrides resolvedMainnetUrl', () {
        const state = NetworkState();
        final copy = state.copyWith(
            resolvedMainnetUrl: 'wss://resolved.mainnet/');
        expect(copy.resolvedMainnetUrl, 'wss://resolved.mainnet/');
      });

      test('can set nullable field to null via sentinel', () {
        const state = NetworkState(
            mainnetCustomUrl: 'wss://custom.example.com/');
        final copy = state.copyWith(mainnetCustomUrl: null);
        expect(copy.mainnetCustomUrl, isNull);
      });

      test('overrides all fields simultaneously', () {
        const state = NetworkState();
        final copy = state.copyWith(
          network: KaspaNetwork.testnet10,
          mainnetCustomUrl: 'wss://a.example.com',
          testnet10CustomUrl: 'wss://b.example.com',
          resolvedMainnetUrl: 'wss://c.example.com',
          resolvedTestnet10Url: 'wss://d.example.com',
        );
        expect(copy.network, KaspaNetwork.testnet10);
        expect(copy.mainnetCustomUrl, 'wss://a.example.com');
        expect(copy.testnet10CustomUrl, 'wss://b.example.com');
        expect(copy.resolvedMainnetUrl, 'wss://c.example.com');
        expect(copy.resolvedTestnet10Url, 'wss://d.example.com');
      });
    });

    group('equality (Equatable)', () {
      test('two default instances are equal', () {
        const a = NetworkState();
        const b = NetworkState();
        expect(a, equals(b));
      });

      test('states with different networks are not equal', () {
        const a = NetworkState(network: KaspaNetwork.mainnet);
        const b = NetworkState(network: KaspaNetwork.testnet10);
        expect(a, isNot(equals(b)));
      });

      test('states with different mainnetCustomUrl are not equal', () {
        const a = NetworkState(mainnetCustomUrl: 'wss://a.example.com');
        const b = NetworkState(mainnetCustomUrl: 'wss://b.example.com');
        expect(a, isNot(equals(b)));
      });

      test('states with different resolvedMainnetUrl are not equal', () {
        const a = NetworkState(resolvedMainnetUrl: 'wss://a.example.com');
        const b = NetworkState(resolvedMainnetUrl: 'wss://b.example.com');
        expect(a, isNot(equals(b)));
      });

      test('props list contains all five fields', () {
        const state = NetworkState();
        expect(state.props, [
          state.network,
          state.mainnetCustomUrl,
          state.testnet10CustomUrl,
          state.resolvedMainnetUrl,
          state.resolvedTestnet10Url,
        ]);
      });
    });
  });

  group('NodeStatusState', () {
    // NodeStatusState lives in its own file, but its properties are closely
    // tied to network — test it here for cohesion.
    // The actual import is from node_status_state.dart.
  });
}
