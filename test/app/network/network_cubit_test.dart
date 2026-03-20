import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NetworkCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // -------------------------------------------------------------------------
    // _load — restores persisted values
    // -------------------------------------------------------------------------
    group('_load — no persisted values', () {
      blocTest<NetworkCubit, NetworkState>(
        'emits mainnet with default URLs when prefs are empty',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<NetworkState>()
              .having((s) => s.network, 'network', KaspaNetwork.mainnet)
              .having(
                  (s) => s.mainnetUrl, 'mainnetUrl', NetworkState.defaultMainnetUrl)
              .having((s) => s.testnet10Url, 'testnet10Url',
                  NetworkState.defaultTestnet10Url),
        ],
      );
    });

    group('_load — persisted values restored', () {
      blocTest<NetworkCubit, NetworkState>(
        'restores testnet10 network from prefs',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'kaspa_network': 'testnet10',
          });
        },
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<NetworkState>().having(
            (s) => s.network,
            'network',
            KaspaNetwork.testnet10,
          ),
        ],
      );

      blocTest<NetworkCubit, NetworkState>(
        'restores custom mainnet URL from prefs',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'kaspa_mainnet_url': 'wss://custom.mainnet.example.com/wrpc/json',
          });
        },
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<NetworkState>().having(
            (s) => s.mainnetUrl,
            'mainnetUrl',
            'wss://custom.mainnet.example.com/wrpc/json',
          ),
        ],
      );

      blocTest<NetworkCubit, NetworkState>(
        'restores custom testnet10 URL from prefs',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'kaspa_testnet10_url': 'wss://custom.testnet.example.com/wrpc/json',
          });
        },
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<NetworkState>().having(
            (s) => s.testnet10Url,
            'testnet10Url',
            'wss://custom.testnet.example.com/wrpc/json',
          ),
        ],
      );

      blocTest<NetworkCubit, NetworkState>(
        'unknown network string falls back to mainnet',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'kaspa_network': 'some_unknown_value',
          });
        },
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<NetworkState>().having(
            (s) => s.network,
            'network',
            KaspaNetwork.mainnet,
          ),
        ],
      );
    });

    // -------------------------------------------------------------------------
    // setNetwork
    // -------------------------------------------------------------------------
    group('setNetwork', () {
      blocTest<NetworkCubit, NetworkState>(
        'emits testnet10 and persists testnet10 string',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.testnet10),
        verify: (cubit) {
          expect(cubit.state.network, KaspaNetwork.testnet10);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'emits mainnet and persists mainnet string',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'kaspa_network': 'testnet10',
          });
        },
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.mainnet),
        verify: (cubit) {
          expect(cubit.state.network, KaspaNetwork.mainnet);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists mainnet string to prefs',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.mainnet),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('kaspa_network'), 'mainnet');
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists testnet10 string to prefs',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.testnet10),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('kaspa_network'), 'testnet10');
        },
      );
    });

    // -------------------------------------------------------------------------
    // setMainnetUrl
    // -------------------------------------------------------------------------
    group('setMainnetUrl', () {
      blocTest<NetworkCubit, NetworkState>(
        'emits new mainnetUrl and persists to prefs',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) =>
            cubit.setMainnetUrl('wss://my-node.example.com/wrpc/json'),
        verify: (cubit) {
          expect(cubit.state.mainnetUrl, 'wss://my-node.example.com/wrpc/json');
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists mainnetUrl to prefs',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) =>
            cubit.setMainnetUrl('wss://my-node.example.com/wrpc/json'),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(
            prefs.getString('kaspa_mainnet_url'),
            'wss://my-node.example.com/wrpc/json',
          );
        },
      );
    });

    // -------------------------------------------------------------------------
    // setTestnet10Url
    // -------------------------------------------------------------------------
    group('setTestnet10Url', () {
      blocTest<NetworkCubit, NetworkState>(
        'emits new testnet10Url and persists to prefs',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) =>
            cubit.setTestnet10Url('wss://my-testnet.example.com/wrpc/json'),
        verify: (cubit) {
          expect(
            cubit.state.testnet10Url,
            'wss://my-testnet.example.com/wrpc/json',
          );
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists testnet10Url to prefs',
        build: () => NetworkCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) =>
            cubit.setTestnet10Url('wss://my-testnet.example.com/wrpc/json'),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(
            prefs.getString('kaspa_testnet10_url'),
            'wss://my-testnet.example.com/wrpc/json',
          );
        },
      );
    });

    // -------------------------------------------------------------------------
    // close
    // -------------------------------------------------------------------------
    group('close', () {
      test('cubit closes without error after _load completes', () async {
        final cubit = NetworkCubit();
        // Wait for async _load to complete before closing
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await expectLater(cubit.close(), completes);
      });
    });
  });
}
