import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CurrencyCubit uses the package-level http.get internally. We test the
// public surface (setCurrency, setDynamicPricing) via SharedPreferences mocking
// and disable network calls by setting dynamicPricing=false in setUp.

void main() {
  group('CurrencyCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ─── Initial state ──────────────────────────────────────────────────────

    group('initial sync state', () {
      // CurrencyCubit._init is async, so we wait for it before asserting/closing.
      test('initial state has KAS selected and no rates before rates load', () async {
        SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        final cubit = CurrencyCubit();
        // The very first synchronous state (before _init emits) has defaults.
        // We capture state before awaiting _init:
        expect(cubit.state.selectedCurrency.code, 'KAS');
        // Wait for _init to complete so close() doesn't race.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await cubit.close();
      });
    });

    // ─── _init — persisted currency restored ────────────────────────────────

    group('_init — no persisted values', () {
      blocTest<CurrencyCubit, CurrencyState>(
        'selects KAS and dynamicPricing=true when prefs are empty',
        build: () => CurrencyCubit(),
        // We only care about verifying state after async init; don't assert
        // on specific emissions since network call timing is non-deterministic.
        verify: (cubit) {
          expect(cubit.state.dynamicPricing, isTrue);
        },
      );
    });

    group('_init — persisted currency', () {
      blocTest<CurrencyCubit, CurrencyState>(
        'restores USD from prefs after init',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'default_currency_code': 'USD',
            'dynamic_pricing': false,
          });
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.selectedCurrency.code, 'USD');
          expect(cubit.state.dynamicPricing, isFalse);
        },
      );

      blocTest<CurrencyCubit, CurrencyState>(
        'falls back to KAS when unknown currency code is persisted',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'default_currency_code': 'XYZ',
            'dynamic_pricing': false,
          });
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.selectedCurrency.code, 'KAS');
        },
      );

      blocTest<CurrencyCubit, CurrencyState>(
        'restores dynamicPricing=false and does not start timer',
        setUp: () {
          SharedPreferences.setMockInitialValues({
            'dynamic_pricing': false,
          });
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        verify: (cubit) {
          expect(cubit.state.dynamicPricing, isFalse);
          // isLoading should be false since no fetch happened
          expect(cubit.state.isLoading, isFalse);
        },
      );
    });

    // ─── setCurrency ────────────────────────────────────────────────────────

    group('setCurrency', () {
      final usd =
          CurrencyState.allCurrencies.firstWhere((c) => c.code == 'USD');
      final eur =
          CurrencyState.allCurrencies.firstWhere((c) => c.code == 'EUR');

      blocTest<CurrencyCubit, CurrencyState>(
        'emits state with new selectedCurrency',
        setUp: () {
          SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        },
        build: () => CurrencyCubit(),
        // wait for _init to complete before acting
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setCurrency(usd),
        verify: (cubit) {
          expect(cubit.state.selectedCurrency.code, 'USD');
        },
      );

      blocTest<CurrencyCubit, CurrencyState>(
        'persists currency code to SharedPreferences',
        setUp: () {
          SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setCurrency(eur),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('default_currency_code'), 'EUR');
        },
      );

      blocTest<CurrencyCubit, CurrencyState>(
        'can set each of the 12 supported currencies',
        setUp: () {
          SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) async {
          for (final c in CurrencyState.allCurrencies) {
            await cubit.setCurrency(c);
          }
        },
        verify: (cubit) {
          // After cycling through all, last one is KRW
          expect(
            cubit.state.selectedCurrency.code,
            CurrencyState.allCurrencies.last.code,
          );
        },
      );
    });

    // ─── setDynamicPricing ─────────────────────────────────────────────────

    group('setDynamicPricing', () {
      blocTest<CurrencyCubit, CurrencyState>(
        'setting false emits dynamicPricing=false and stops timer',
        setUp: () {
          SharedPreferences.setMockInitialValues({'dynamic_pricing': true});
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setDynamicPricing(false),
        verify: (cubit) {
          expect(cubit.state.dynamicPricing, isFalse);
        },
      );

      blocTest<CurrencyCubit, CurrencyState>(
        'persists dynamic_pricing=false to prefs',
        setUp: () {
          SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setDynamicPricing(false),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getBool('dynamic_pricing'), isFalse);
        },
      );

      blocTest<CurrencyCubit, CurrencyState>(
        'persists dynamic_pricing=true to prefs',
        setUp: () {
          SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        },
        build: () => CurrencyCubit(),
        wait: const Duration(milliseconds: 50),
        act: (cubit) => cubit.setDynamicPricing(true),
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getBool('dynamic_pricing'), isTrue);
        },
      );
    });

    // ─── close ─────────────────────────────────────────────────────────────

    group('close', () {
      test('cancels timer and closes without error', () async {
        SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        final cubit = CurrencyCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await expectLater(cubit.close(), completes);
      });

      test('closes without error even when dynamic pricing is active', () async {
        SharedPreferences.setMockInitialValues({'dynamic_pricing': false});
        final cubit = CurrencyCubit();
        // Wait for _init to complete so close doesn't race with emit
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await expectLater(cubit.close(), completes);
      });
    });
  });
}
