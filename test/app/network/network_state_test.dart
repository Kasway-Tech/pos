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

      test('defaults to correct mainnet URL', () {
        const state = NetworkState();
        expect(state.mainnetUrl, NetworkState.defaultMainnetUrl);
        expect(
          state.mainnetUrl,
          'wss://rose.kaspa.green/kaspa/mainnet/wrpc/json',
        );
      });

      test('defaults to correct testnet10 URL', () {
        const state = NetworkState();
        expect(state.testnet10Url, NetworkState.defaultTestnet10Url);
        expect(
          state.testnet10Url,
          'wss://electron-10.kaspa.stream/kaspa/testnet-10/wrpc/json',
        );
      });
    });

    group('activeUrl', () {
      test('returns mainnetUrl when network is mainnet', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(state.activeUrl, state.mainnetUrl);
      });

      test('returns testnet10Url when network is testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(state.activeUrl, state.testnet10Url);
      });

      test('returns custom mainnet URL when set', () {
        const customUrl = 'wss://my-node.example.com/kaspa/mainnet/wrpc/json';
        const state = NetworkState(
          network: KaspaNetwork.mainnet,
          mainnetUrl: customUrl,
        );
        expect(state.activeUrl, customUrl);
      });

      test('returns custom testnet10 URL when set', () {
        const customUrl =
            'wss://my-node.example.com/kaspa/testnet-10/wrpc/json';
        const state = NetworkState(
          network: KaspaNetwork.testnet10,
          testnet10Url: customUrl,
        );
        expect(state.activeUrl, customUrl);
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
      test('replaces /json with /borsh in mainnet URL', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(
          state.activeBorshUrl,
          'wss://rose.kaspa.green/kaspa/mainnet/wrpc/borsh',
        );
      });

      test('replaces /json with /borsh in testnet10 URL', () {
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
          mainnetUrl: customUrl,
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
        expect(
          state.explorerBaseUrl,
          'https://kaspa.stream/transactions/',
        );
      });

      test('returns testnet explorer URL for testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(
          state.explorerBaseUrl,
          'https://tn10.kaspa.stream/transactions/',
        );
      });
    });

    group('explorerAddressBaseUrl', () {
      test('returns mainnet address explorer URL for mainnet', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        expect(
          state.explorerAddressBaseUrl,
          'https://kaspa.stream/addresses/',
        );
      });

      test('returns testnet address explorer URL for testnet10', () {
        const state = NetworkState(network: KaspaNetwork.testnet10);
        expect(
          state.explorerAddressBaseUrl,
          'https://tn10.kaspa.stream/addresses/',
        );
      });
    });

    group('copyWith', () {
      test('returns identical state when no overrides provided', () {
        const state = NetworkState();
        final copy = state.copyWith();
        expect(copy.network, state.network);
        expect(copy.mainnetUrl, state.mainnetUrl);
        expect(copy.testnet10Url, state.testnet10Url);
      });

      test('overrides network', () {
        const state = NetworkState(network: KaspaNetwork.mainnet);
        final copy = state.copyWith(network: KaspaNetwork.testnet10);
        expect(copy.network, KaspaNetwork.testnet10);
        expect(copy.mainnetUrl, state.mainnetUrl);
        expect(copy.testnet10Url, state.testnet10Url);
      });

      test('overrides mainnetUrl', () {
        const newUrl = 'wss://new-node.example.com/kaspa/mainnet/wrpc/json';
        const state = NetworkState();
        final copy = state.copyWith(mainnetUrl: newUrl);
        expect(copy.mainnetUrl, newUrl);
        expect(copy.network, state.network);
        expect(copy.testnet10Url, state.testnet10Url);
      });

      test('overrides testnet10Url', () {
        const newUrl =
            'wss://new-node.example.com/kaspa/testnet-10/wrpc/json';
        const state = NetworkState();
        final copy = state.copyWith(testnet10Url: newUrl);
        expect(copy.testnet10Url, newUrl);
        expect(copy.network, state.network);
        expect(copy.mainnetUrl, state.mainnetUrl);
      });

      test('overrides all fields simultaneously', () {
        const state = NetworkState();
        final copy = state.copyWith(
          network: KaspaNetwork.testnet10,
          mainnetUrl: 'wss://a.example.com',
          testnet10Url: 'wss://b.example.com',
        );
        expect(copy.network, KaspaNetwork.testnet10);
        expect(copy.mainnetUrl, 'wss://a.example.com');
        expect(copy.testnet10Url, 'wss://b.example.com');
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

      test('states with different mainnetUrl are not equal', () {
        const a = NetworkState(mainnetUrl: 'wss://a.example.com');
        const b = NetworkState(mainnetUrl: 'wss://b.example.com');
        expect(a, isNot(equals(b)));
      });

      test('states with different testnet10Url are not equal', () {
        const a = NetworkState(testnet10Url: 'wss://a.example.com');
        const b = NetworkState(testnet10Url: 'wss://b.example.com');
        expect(a, isNot(equals(b)));
      });

      test('props list contains all three fields', () {
        const state = NetworkState();
        expect(state.props, [
          state.network,
          state.mainnetUrl,
          state.testnet10Url,
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
