import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/data/services/kaspa_resolver_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockKaspaResolverService extends Mock implements KaspaResolverService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 5));
    registerFallbackValue(KaspaNetwork.mainnet);
  });

  group('NetworkCubit', () {
    late MockKaspaResolverService mockResolver;

    setUp(() {
      mockResolver = MockKaspaResolverService();
      // Default: resolver returns valid URLs for both networks.
      when(() => mockResolver.resolve(
            KaspaNetwork.mainnet,
            timeout: any(named: 'timeout'),
          )).thenAnswer(
              (_) async => 'wss://resolved.kaspa.stream/mainnet/wrpc/json');
      when(() => mockResolver.resolve(
            KaspaNetwork.testnet10,
            timeout: any(named: 'timeout'),
          )).thenAnswer(
              (_) async => 'wss://resolved.kaspa.stream/testnet-10/wrpc/json');
    });

    NetworkCubit buildCubit() =>
        NetworkCubit(resolverService: mockResolver);

    // -------------------------------------------------------------------------
    // _load + resolver
    // -------------------------------------------------------------------------
    group('_load and resolver', () {
      blocTest<NetworkCubit, NetworkState>(
        'emits resolved URLs in auto mode on startup',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.resolvedMainnetUrl,
              'wss://resolved.kaspa.stream/mainnet/wrpc/json');
          expect(cubit.state.isAutoMode, isTrue);
          expect(cubit.state.mainnetCustomUrl, isNull);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'restores testnet10 network from prefs',
        setUp: () => SharedPreferences.setMockInitialValues({
          'kaspa_network': 'testnet10',
        }),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.network, KaspaNetwork.testnet10);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'unknown network string falls back to mainnet',
        setUp: () => SharedPreferences.setMockInitialValues({
          'kaspa_network': 'some_unknown_value',
        }),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.network, KaspaNetwork.mainnet);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'uses custom URL from prefs and isAutoMode is false',
        setUp: () => SharedPreferences.setMockInitialValues({
          PreferenceKeys.kaspaMainnetCustomUrl:
              'wss://custom.example.com/wrpc/json',
        }),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.mainnetCustomUrl,
              'wss://custom.example.com/wrpc/json');
          expect(cubit.state.isAutoMode, isFalse);
          // activeUrl should use the custom URL, not the resolved/fallback URL.
          expect(cubit.state.activeUrl,
              'wss://custom.example.com/wrpc/json');
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'migrates old pref key to new custom key on first load',
        setUp: () => SharedPreferences.setMockInitialValues({
          PreferenceKeys.kaspaMainnetUrl:
              'wss://my-old-custom.example.com/',
        }),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.mainnetCustomUrl,
              'wss://my-old-custom.example.com/');
          expect(cubit.state.isAutoMode, isFalse);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'does NOT migrate old pref key when it equals the fallback URL',
        setUp: () => SharedPreferences.setMockInitialValues({
          PreferenceKeys.kaspaMainnetUrl: NetworkState.fallbackMainnetUrl,
        }),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          // Old key held the default — should stay in auto mode.
          expect(cubit.state.mainnetCustomUrl, isNull);
          expect(cubit.state.isAutoMode, isTrue);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'falls back to hardcoded URL when resolver returns null',
        setUp: () {
          SharedPreferences.setMockInitialValues({});
          when(() => mockResolver.resolve(
                KaspaNetwork.mainnet,
                timeout: any(named: 'timeout'),
              )).thenAnswer((_) async => null);
        },
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.resolvedMainnetUrl, isNull);
          expect(cubit.state.activeUrl, NetworkState.fallbackMainnetUrl);
        },
      );
    });

    // -------------------------------------------------------------------------
    // setNetwork
    // -------------------------------------------------------------------------
    group('setNetwork', () {
      blocTest<NetworkCubit, NetworkState>(
        'emits testnet10 and persists testnet10 string',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.testnet10),
        verify: (cubit) {
          expect(cubit.state.network, KaspaNetwork.testnet10);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'emits mainnet and persists mainnet string',
        setUp: () => SharedPreferences.setMockInitialValues({
          'kaspa_network': 'testnet10',
        }),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.mainnet),
        verify: (cubit) {
          expect(cubit.state.network, KaspaNetwork.mainnet);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists mainnet string to prefs',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.mainnet),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('kaspa_network'), 'mainnet');
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists testnet10 string to prefs',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setNetwork(KaspaNetwork.testnet10),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('kaspa_network'), 'testnet10');
        },
      );
    });

    // -------------------------------------------------------------------------
    // setCustomMainnetUrl / setCustomTestnet10Url
    // -------------------------------------------------------------------------
    group('setCustomMainnetUrl', () {
      blocTest<NetworkCubit, NetworkState>(
        'saves URL and emits state with isAutoMode false',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.setCustomMainnetUrl(
              'wss://my-node.example.com/wrpc/json');
        },
        verify: (cubit) {
          expect(cubit.state.mainnetCustomUrl,
              'wss://my-node.example.com/wrpc/json');
          expect(cubit.state.isAutoMode, isFalse);
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists custom mainnet URL to prefs',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.setCustomMainnetUrl(
              'wss://my-node.example.com/wrpc/json');
        },
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(
            prefs.getString(PreferenceKeys.kaspaMainnetCustomUrl),
            'wss://my-node.example.com/wrpc/json',
          );
        },
      );
    });

    group('setCustomTestnet10Url', () {
      blocTest<NetworkCubit, NetworkState>(
        'saves URL and emits new testnet10CustomUrl',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.setCustomTestnet10Url(
              'wss://my-testnet.example.com/wrpc/json');
        },
        verify: (cubit) {
          expect(cubit.state.testnet10CustomUrl,
              'wss://my-testnet.example.com/wrpc/json');
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'persists custom testnet10 URL to prefs',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.setCustomTestnet10Url(
              'wss://my-testnet.example.com/wrpc/json');
        },
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(
            prefs.getString(PreferenceKeys.kaspaTestnet10CustomUrl),
            'wss://my-testnet.example.com/wrpc/json',
          );
        },
      );
    });

    // -------------------------------------------------------------------------
    // resetToAuto
    // -------------------------------------------------------------------------
    group('resetToAuto', () {
      blocTest<NetworkCubit, NetworkState>(
        'clears custom URL and transitions back to auto mode',
        setUp: () => SharedPreferences.setMockInitialValues({
          PreferenceKeys.kaspaMainnetCustomUrl: 'wss://custom.example.com/',
        }),
        build: buildCubit,
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await cubit.resetToAuto(KaspaNetwork.mainnet);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          expect(cubit.state.mainnetCustomUrl, isNull);
          expect(cubit.state.isAutoMode, isTrue);
          // Resolver must have been called at least once (either during load
          // or after resetToAuto).
          verify(() => mockResolver.resolve(
                KaspaNetwork.mainnet,
                timeout: any(named: 'timeout'),
              )).called(greaterThan(0));
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'removes custom URL from prefs',
        setUp: () => SharedPreferences.setMockInitialValues({
          PreferenceKeys.kaspaMainnetCustomUrl: 'wss://custom.example.com/',
        }),
        build: buildCubit,
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await cubit.resetToAuto(KaspaNetwork.mainnet);
        },
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(
              prefs.getString(PreferenceKeys.kaspaMainnetCustomUrl), isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // triggerResolve
    // -------------------------------------------------------------------------
    group('triggerResolve', () {
      blocTest<NetworkCubit, NetworkState>(
        'calls resolver in auto mode',
        setUp: () => SharedPreferences.setMockInitialValues({}),
        build: buildCubit,
        act: (cubit) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await cubit.triggerResolve();
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          verify(() => mockResolver.resolve(
                any(),
                timeout: any(named: 'timeout'),
              )).called(greaterThan(0));
        },
      );

      blocTest<NetworkCubit, NetworkState>(
        'does nothing in custom URL mode',
        setUp: () => SharedPreferences.setMockInitialValues({
          PreferenceKeys.kaspaMainnetCustomUrl: 'wss://custom.example.com/',
          PreferenceKeys.kaspaTestnet10CustomUrl: 'wss://custom-tn.example.com/',
        }),
        build: buildCubit,
        act: (cubit) async {
          // Wait for the initial _resolveAll (triggered by _load) to finish,
          // then reset interaction counts before calling triggerResolve.
          await Future<void>.delayed(const Duration(milliseconds: 50));
          // Re-stub after clearing so the mock still has valid stubs.
          clearInteractions(mockResolver);
          when(() => mockResolver.resolve(any(),
                  timeout: any(named: 'timeout')))
              .thenAnswer((_) async => null);
          await cubit.triggerResolve();
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          // Active network is mainnet which has a custom URL — triggerResolve
          // checks isAutoMode (false) and is a no-op.
          verifyNever(() => mockResolver.resolve(
                KaspaNetwork.mainnet,
                timeout: any(named: 'timeout'),
              ));
        },
      );
    });

    // -------------------------------------------------------------------------
    // close
    // -------------------------------------------------------------------------
    group('close', () {
      test('cubit closes without error after _load completes', () async {
        SharedPreferences.setMockInitialValues({});
        final cubit = NetworkCubit(resolverService: mockResolver);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await expectLater(cubit.close(), completes);
      });
    });
  });
}
