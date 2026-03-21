import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_state.dart';

void main() {
  // Shared exchange rates used across tests:
  //   1 KAS = 1 000 IDR, 0.075 USD, 0.068 EUR, 0.059 GBP,
  //   11.0 JPY, 0.10 SGD, 0.34 MYR, 0.116 AUD, 0.54 CNY,
  //   0.585 HKD, 99.0 KRW
  const rates = <String, double>{
    'idr': 1000.0,
    'usd': 0.075,
    'eur': 0.068,
    'gbp': 0.059,
    'jpy': 11.0,
    'sgd': 0.10,
    'myr': 0.34,
    'aud': 0.116,
    'cny': 0.54,
    'hkd': 0.585,
    'krw': 99.0,
  };

  // Helper: build a state with a given selectedCurrency and the shared rates.
  CurrencyState stateFor(String code) {
    final currency = CurrencyState.allCurrencies.firstWhere(
      (c) => c.code == code,
    );
    return CurrencyState(
      selectedCurrency: currency,
      exchangeRates: rates,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // allCurrencies
  // ──────────────────────────────────────────────────────────────
  group('allCurrencies', () {
    test('contains expected number of currencies', () {
      expect(CurrencyState.allCurrencies.length, 26);
    });

    test('first currency is KAS', () {
      expect(CurrencyState.allCurrencies.first.code, 'KAS');
      expect(CurrencyState.allCurrencies.first.isCrypto, isTrue);
    });

    test('contains all expected codes', () {
      final codes =
          CurrencyState.allCurrencies.map((c) => c.code).toSet();
      expect(
        codes,
        containsAll(
          ['KAS', 'IDR', 'USD', 'EUR', 'GBP', 'JPY', 'SGD', 'MYR', 'AUD', 'CNY', 'HKD', 'KRW'],
        ),
      );
    });

    test('fiat currencies have isCrypto == false', () {
      for (final c in CurrencyState.allCurrencies) {
        if (c.code != 'KAS') {
          expect(c.isCrypto, isFalse, reason: '${c.code} should not be crypto');
        }
      }
    });
  });

  // ──────────────────────────────────────────────────────────────
  // Default / initial state
  // ──────────────────────────────────────────────────────────────
  group('default state', () {
    test('selectedCurrency defaults to KAS', () {
      expect(const CurrencyState().selectedCurrency.code, 'KAS');
    });

    test('exchangeRates defaults to empty', () {
      expect(const CurrencyState().exchangeRates, isEmpty);
    });

    test('dynamicPricing defaults to true', () {
      expect(const CurrencyState().dynamicPricing, isTrue);
    });

    test('isLoading defaults to false', () {
      expect(const CurrencyState().isLoading, isFalse);
    });

    test('lastFetchedAt defaults to null', () {
      expect(const CurrencyState().lastFetchedAt, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // copyWith
  // ──────────────────────────────────────────────────────────────
  group('copyWith', () {
    test('returns identical state when no args provided', () {
      const s = CurrencyState();
      final copy = s.copyWith();
      expect(copy, equals(s));
    });

    test('overrides individual fields', () {
      const s = CurrencyState();
      final usd = CurrencyState.allCurrencies.firstWhere((c) => c.code == 'USD');
      final copy = s.copyWith(
        selectedCurrency: usd,
        isLoading: true,
        dynamicPricing: false,
        exchangeRates: {'idr': 500.0},
      );
      expect(copy.selectedCurrency.code, 'USD');
      expect(copy.isLoading, isTrue);
      expect(copy.dynamicPricing, isFalse);
      expect(copy.exchangeRates, {'idr': 500.0});
      expect(copy.lastFetchedAt, isNull);
    });

    test('preserves unchanged fields', () {
      final now = DateTime(2024, 1, 1);
      final s = CurrencyState(
        exchangeRates: rates,
        dynamicPricing: false,
        isLoading: true,
        lastFetchedAt: now,
      );
      final copy = s.copyWith(isLoading: false);
      expect(copy.exchangeRates, rates);
      expect(copy.dynamicPricing, isFalse);
      expect(copy.lastFetchedAt, now);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // Equatable / props
  // ──────────────────────────────────────────────────────────────
  group('equality', () {
    test('equal states compare equal', () {
      final s1 = CurrencyState(exchangeRates: rates);
      final s2 = CurrencyState(exchangeRates: rates);
      expect(s1, equals(s2));
    });

    test('states with different selectedCurrency are not equal', () {
      final s1 = stateFor('USD');
      final s2 = stateFor('EUR');
      expect(s1, isNot(equals(s2)));
    });

    test('states with different isLoading are not equal', () {
      final s1 = CurrencyState(exchangeRates: rates, isLoading: true);
      final s2 = CurrencyState(exchangeRates: rates, isLoading: false);
      expect(s1, isNot(equals(s2)));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // formatPrice — KAS (display currency)
  // ──────────────────────────────────────────────────────────────
  group('formatPrice — KAS', () {
    test('formats IDR price as KAS using exchange rate', () {
      final s = stateFor('KAS');
      // 10 000 IDR / 1 000 IDR-per-KAS = 10.0000 KAS
      expect(s.formatPrice(10000), 'KAS 10.0000');
    });

    test('uses provided kasPrice when available', () {
      final s = stateFor('KAS');
      expect(s.formatPrice(10000, kasPrice: 5.0), 'KAS 5.0000');
    });

    test('respects custom kasSymbol', () {
      final s = stateFor('KAS');
      expect(s.formatPrice(10000, kasSymbol: 'TKAS'), 'TKAS 10.0000');
    });

    test('falls back to IDR when kasIdr is 0', () {
      const s = CurrencyState(); // empty rates → kasIdr = 0
      // With kasIdr <= 0 the method falls back to IDR formatting
      final result = s.formatPrice(10000);
      expect(result, contains('IDR'));
      expect(result, contains('10'));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // formatPrice — IDR (display currency)
  // ──────────────────────────────────────────────────────────────
  group('formatPrice — IDR', () {
    test('formats as IDR with no decimal digits', () {
      final s = stateFor('IDR');
      final result = s.formatPrice(50000);
      expect(result, contains('IDR'));
      expect(result, contains('50.000')); // Indonesian locale uses dots as thousands sep
    });

    test('shows IDR when exchange rates are empty regardless of selected currency', () {
      const s = CurrencyState(); // KAS selected, no rates
      final result = s.formatPrice(25000);
      expect(result, contains('IDR'));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // formatPrice — USD
  // ──────────────────────────────────────────────────────────────
  group('formatPrice — USD', () {
    test('converts IDR to USD with 2 decimal digits', () {
      final s = stateFor('USD');
      // 10 000 IDR / 1 000 IDR-per-KAS × 0.075 USD-per-KAS = 0.75 USD
      final result = s.formatPrice(10000);
      expect(result, contains('USD'));
      expect(result, contains('0.75'));
    });

    test('uses provided kasPrice for USD conversion', () {
      final s = stateFor('USD');
      // kasPrice=10.0 × 0.075 = 0.75
      final result = s.formatPrice(0, kasPrice: 10.0);
      expect(result, contains('USD'));
      expect(result, contains('0.75'));
    });

    test('returns placeholder when USD rate missing', () {
      final currency = CurrencyState.allCurrencies.firstWhere((c) => c.code == 'USD');
      // Provide idr rate only; usd rate absent → kasTarget = 0
      final s = CurrencyState(
        selectedCurrency: currency,
        exchangeRates: const {'idr': 1000.0},
      );
      expect(s.formatPrice(10000), '-- USD');
    });
  });

  // ──────────────────────────────────────────────────────────────
  // formatPrice — JPY (zero decimal digits)
  // ──────────────────────────────────────────────────────────────
  group('formatPrice — JPY', () {
    test('formats JPY with 0 decimal digits', () {
      final s = stateFor('JPY');
      // 100 000 IDR / 1 000 × 11.0 = 1 100 JPY
      final result = s.formatPrice(100000);
      expect(result, contains('JPY'));
      // Should not contain a decimal point in the amount
      expect(result, isNot(contains('.')));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // formatPrice — KRW (zero decimal digits)
  // ──────────────────────────────────────────────────────────────
  group('formatPrice — KRW', () {
    test('formats KRW with 0 decimal digits', () {
      final s = stateFor('KRW');
      final result = s.formatPrice(10000);
      expect(result, contains('KRW'));
      expect(result, isNot(contains('.')));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // formatPrice — EUR, GBP, SGD, MYR, AUD, CNY, HKD (2 decimals)
  // ──────────────────────────────────────────────────────────────
  group('formatPrice — other fiat currencies (2 decimals)', () {
    for (final code in ['EUR', 'GBP', 'SGD', 'MYR', 'AUD', 'CNY', 'HKD']) {
      test('$code result contains currency code', () {
        final s = stateFor(code);
        final result = s.formatPrice(10000);
        expect(result, contains(code));
      });
    }

    test('EUR converts correctly', () {
      final s = stateFor('EUR');
      // 10 000 / 1 000 × 0.068 = 0.68 EUR
      final result = s.formatPrice(10000);
      expect(result, contains('0.68'));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // formatPrice — edge cases
  // ──────────────────────────────────────────────────────────────
  group('formatPrice — edge cases', () {
    test('zero idrPrice returns zero-valued string', () {
      final s = stateFor('USD');
      final result = s.formatPrice(0);
      expect(result, contains('0'));
    });

    test('large idrPrice does not throw', () {
      final s = stateFor('KAS');
      expect(() => s.formatPrice(1e12), returnsNormally);
    });

    test('negative idrPrice does not throw', () {
      final s = stateFor('IDR');
      expect(() => s.formatPrice(-1000), returnsNormally);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // idrToDisplay
  // ──────────────────────────────────────────────────────────────
  group('idrToDisplay', () {
    test('returns idrPrice unchanged when selectedCurrency is IDR', () {
      final s = stateFor('IDR');
      expect(s.idrToDisplay(50000), 50000);
    });

    test('returns idrPrice unchanged when kasIdr is 0', () {
      // No rates → kasIdr = 0, falls back
      const s = CurrencyState();
      expect(s.idrToDisplay(50000), 50000);
    });

    test('converts IDR to KAS', () {
      final s = stateFor('KAS');
      expect(s.idrToDisplay(10000), closeTo(10.0, 0.0001));
    });

    test('uses provided kasPrice for KAS', () {
      final s = stateFor('KAS');
      expect(s.idrToDisplay(10000, kasPrice: 7.5), 7.5);
    });

    test('converts IDR to USD', () {
      final s = stateFor('USD');
      // 10 000 / 1 000 × 0.075 = 0.75
      expect(s.idrToDisplay(10000), closeTo(0.75, 0.0001));
    });

    test('returns idrPrice when target fiat rate is 0', () {
      final currency =
          CurrencyState.allCurrencies.firstWhere((c) => c.code == 'USD');
      final s = CurrencyState(
        selectedCurrency: currency,
        exchangeRates: const {'idr': 1000.0}, // no usd rate
      );
      expect(s.idrToDisplay(10000), 10000);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // displayToKas
  // ──────────────────────────────────────────────────────────────
  group('displayToKas', () {
    test('returns displayAmount directly when currency is KAS', () {
      final s = stateFor('KAS');
      expect(s.displayToKas(5.0), 5.0);
    });

    test('converts IDR display amount to KAS', () {
      final s = stateFor('IDR');
      // 10 000 IDR / 1 000 IDR-per-KAS = 10 KAS
      expect(s.displayToKas(10000), closeTo(10.0, 0.0001));
    });

    test('returns null when IDR rate is 0 for IDR currency', () {
      final currency =
          CurrencyState.allCurrencies.firstWhere((c) => c.code == 'IDR');
      final s = CurrencyState(selectedCurrency: currency);
      expect(s.displayToKas(10000), isNull);
    });

    test('converts USD display amount to KAS', () {
      final s = stateFor('USD');
      // 0.75 USD / 0.075 USD-per-KAS = 10 KAS
      expect(s.displayToKas(0.75), closeTo(10.0, 0.0001));
    });

    test('returns null when target fiat rate is 0', () {
      final currency =
          CurrencyState.allCurrencies.firstWhere((c) => c.code == 'USD');
      final s = CurrencyState(
        selectedCurrency: currency,
        exchangeRates: const {'idr': 1000.0}, // no usd rate
      );
      expect(s.displayToKas(0.75), isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // displayToIdr
  // ──────────────────────────────────────────────────────────────
  group('displayToIdr', () {
    test('returns displayAmount unchanged when currency is IDR', () {
      final s = stateFor('IDR');
      expect(s.displayToIdr(50000), 50000);
    });

    test('returns displayAmount unchanged when kasIdr is 0', () {
      const s = CurrencyState();
      expect(s.displayToIdr(50000), 50000);
    });

    test('converts KAS display amount to IDR', () {
      final s = stateFor('KAS');
      // 10 KAS × 1 000 IDR-per-KAS = 10 000 IDR
      expect(s.displayToIdr(10.0), closeTo(10000, 0.001));
    });

    test('converts USD display amount to IDR', () {
      final s = stateFor('USD');
      // 0.75 USD × (1 000 / 0.075) = 10 000 IDR
      expect(s.displayToIdr(0.75), closeTo(10000, 0.001));
    });

    test('returns displayAmount when target fiat rate is 0', () {
      final currency =
          CurrencyState.allCurrencies.firstWhere((c) => c.code == 'USD');
      final s = CurrencyState(
        selectedCurrency: currency,
        exchangeRates: const {'idr': 1000.0}, // no usd rate
      );
      expect(s.displayToIdr(0.75), 0.75);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // Currency model
  // ──────────────────────────────────────────────────────────────
  group('Currency', () {
    const c = Currency(code: 'USD', name: 'US Dollar', flag: '🇺🇸');

    test('displayName concatenates name and code', () {
      expect(c.displayName, 'US Dollar (USD)');
    });

    test('isCrypto defaults to false', () {
      expect(c.isCrypto, isFalse);
    });

    test('iconPath defaults to null', () {
      expect(c.iconPath, isNull);
    });

    test('crypto currency with iconPath', () {
      const kas = Currency(
        code: 'KAS',
        name: 'Kaspa',
        flag: '',
        isCrypto: true,
        iconPath: 'assets/svg/payment_methods/kaspa.svg',
      );
      expect(kas.isCrypto, isTrue);
      expect(kas.iconPath, isNotNull);
    });
  });
}
