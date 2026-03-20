import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/donation/donation_cubit.dart';
import 'package:kasway/app/donation/donation_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DonationState', () {
    group('default values', () {
      test('autoEnabled defaults to false', () {
        expect(const DonationState().autoEnabled, isFalse);
      });

      test('mode defaults to percentage', () {
        expect(const DonationState().mode, DonationMode.percentage);
      });

      test('percentageValue defaults to 1.0', () {
        expect(const DonationState().percentageValue, 1.0);
      });

      test('fixedKasAmount defaults to 1.0', () {
        expect(const DonationState().fixedKasAmount, 1.0);
      });
    });

    group('copyWith', () {
      test('returns identical state when no args provided', () {
        const s = DonationState();
        final copy = s.copyWith();
        expect(copy.autoEnabled, s.autoEnabled);
        expect(copy.mode, s.mode);
        expect(copy.percentageValue, s.percentageValue);
        expect(copy.fixedKasAmount, s.fixedKasAmount);
      });

      test('overrides autoEnabled', () {
        const s = DonationState();
        final copy = s.copyWith(autoEnabled: true);
        expect(copy.autoEnabled, isTrue);
        expect(copy.mode, s.mode);
      });

      test('overrides mode to fixedAmount', () {
        const s = DonationState();
        final copy = s.copyWith(mode: DonationMode.fixedAmount);
        expect(copy.mode, DonationMode.fixedAmount);
        expect(copy.autoEnabled, s.autoEnabled);
      });

      test('overrides percentageValue', () {
        const s = DonationState();
        final copy = s.copyWith(percentageValue: 5.0);
        expect(copy.percentageValue, 5.0);
        expect(copy.fixedKasAmount, s.fixedKasAmount);
      });

      test('overrides fixedKasAmount', () {
        const s = DonationState();
        final copy = s.copyWith(fixedKasAmount: 10.0);
        expect(copy.fixedKasAmount, 10.0);
        expect(copy.percentageValue, s.percentageValue);
      });
    });

    group('DonationConstants', () {
      test('address is a valid kaspa: address', () {
        expect(DonationConstants.address, startsWith('kaspa:'));
        expect(DonationConstants.address, isNotEmpty);
      });
    });

    group('DonationMode enum', () {
      test('has two values', () {
        expect(DonationMode.values.length, 2);
        expect(DonationMode.values, containsAll([DonationMode.percentage, DonationMode.fixedAmount]));
      });
    });
  });

  group('DonationCubit', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    DonationCubit buildCubit() => DonationCubit(prefs: prefs);

    group('initial load — no persisted values', () {
      test('initial state has defaults when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.autoEnabled, isFalse);
        expect(cubit.state.mode, DonationMode.percentage);
        expect(cubit.state.percentageValue, 1.0);
        expect(cubit.state.fixedKasAmount, 1.0);
      });
    });

    group('initial load — persisted values restored', () {
      test('loads autoEnabled=true from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'donation_auto_enabled': true,
        });
        final p = await SharedPreferences.getInstance();
        final cubit = DonationCubit(prefs: p);
        expect(cubit.state.autoEnabled, isTrue);
      });

      test('loads fixedAmount mode from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'donation_mode': 'fixedAmount',
        });
        final p = await SharedPreferences.getInstance();
        final cubit = DonationCubit(prefs: p);
        expect(cubit.state.mode, DonationMode.fixedAmount);
      });

      test('loads percentage mode from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'donation_mode': 'percentage',
        });
        final p = await SharedPreferences.getInstance();
        final cubit = DonationCubit(prefs: p);
        expect(cubit.state.mode, DonationMode.percentage);
      });

      test('unknown mode string defaults to percentage', () async {
        SharedPreferences.setMockInitialValues({
          'donation_mode': 'unknown',
        });
        final p = await SharedPreferences.getInstance();
        final cubit = DonationCubit(prefs: p);
        expect(cubit.state.mode, DonationMode.percentage);
      });

      test('loads custom percentageValue from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'donation_percentage': 3.5,
        });
        final p = await SharedPreferences.getInstance();
        final cubit = DonationCubit(prefs: p);
        expect(cubit.state.percentageValue, 3.5);
      });

      test('loads custom fixedKasAmount from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'donation_fixed_kas': 5.0,
        });
        final p = await SharedPreferences.getInstance();
        final cubit = DonationCubit(prefs: p);
        expect(cubit.state.fixedKasAmount, 5.0);
      });
    });

    group('setAutoEnabled', () {
      blocTest<DonationCubit, DonationState>(
        'emits state with autoEnabled=true and persists to prefs',
        build: buildCubit,
        act: (cubit) => cubit.setAutoEnabled(true),
        expect: () => [
          isA<DonationState>().having((s) => s.autoEnabled, 'autoEnabled', true),
        ],
        verify: (_) {
          expect(prefs.getBool('donation_auto_enabled'), isTrue);
        },
      );

      blocTest<DonationCubit, DonationState>(
        'emits state with autoEnabled=false and persists to prefs',
        setUp: () async {
          SharedPreferences.setMockInitialValues({'donation_auto_enabled': true});
          prefs = await SharedPreferences.getInstance();
        },
        build: buildCubit,
        act: (cubit) => cubit.setAutoEnabled(false),
        expect: () => [
          isA<DonationState>().having((s) => s.autoEnabled, 'autoEnabled', false),
        ],
        verify: (_) {
          expect(prefs.getBool('donation_auto_enabled'), isFalse);
        },
      );
    });

    group('setMode', () {
      blocTest<DonationCubit, DonationState>(
        'emits fixedAmount mode and persists fixedAmount string',
        build: buildCubit,
        act: (cubit) => cubit.setMode(DonationMode.fixedAmount),
        expect: () => [
          isA<DonationState>().having((s) => s.mode, 'mode', DonationMode.fixedAmount),
        ],
        verify: (_) {
          expect(prefs.getString('donation_mode'), 'fixedAmount');
        },
      );

      blocTest<DonationCubit, DonationState>(
        'emits percentage mode and persists percentage string',
        setUp: () async {
          SharedPreferences.setMockInitialValues({'donation_mode': 'fixedAmount'});
          prefs = await SharedPreferences.getInstance();
        },
        build: buildCubit,
        act: (cubit) => cubit.setMode(DonationMode.percentage),
        expect: () => [
          isA<DonationState>().having((s) => s.mode, 'mode', DonationMode.percentage),
        ],
        verify: (_) {
          expect(prefs.getString('donation_mode'), 'percentage');
        },
      );
    });

    group('setPercentage', () {
      blocTest<DonationCubit, DonationState>(
        'emits new percentageValue and persists to prefs',
        build: buildCubit,
        act: (cubit) => cubit.setPercentage(2.5),
        expect: () => [
          isA<DonationState>().having(
            (s) => s.percentageValue,
            'percentageValue',
            2.5,
          ),
        ],
        verify: (_) {
          expect(prefs.getDouble('donation_percentage'), 2.5);
        },
      );

      blocTest<DonationCubit, DonationState>(
        'emits 0.0 percentageValue (boundary)',
        build: buildCubit,
        act: (cubit) => cubit.setPercentage(0.0),
        expect: () => [
          isA<DonationState>().having(
            (s) => s.percentageValue,
            'percentageValue',
            0.0,
          ),
        ],
      );

      blocTest<DonationCubit, DonationState>(
        'emits 100.0 percentageValue (max boundary)',
        build: buildCubit,
        act: (cubit) => cubit.setPercentage(100.0),
        expect: () => [
          isA<DonationState>().having(
            (s) => s.percentageValue,
            'percentageValue',
            100.0,
          ),
        ],
      );
    });

    group('setFixedAmount', () {
      blocTest<DonationCubit, DonationState>(
        'emits new fixedKasAmount and persists to prefs',
        build: buildCubit,
        act: (cubit) => cubit.setFixedAmount(10.0),
        expect: () => [
          isA<DonationState>().having(
            (s) => s.fixedKasAmount,
            'fixedKasAmount',
            10.0,
          ),
        ],
        verify: (_) {
          expect(prefs.getDouble('donation_fixed_kas'), 10.0);
        },
      );

      blocTest<DonationCubit, DonationState>(
        'emits 0.0 fixedKasAmount (boundary)',
        build: buildCubit,
        act: (cubit) => cubit.setFixedAmount(0.0),
        expect: () => [
          isA<DonationState>().having(
            (s) => s.fixedKasAmount,
            'fixedKasAmount',
            0.0,
          ),
        ],
      );
    });

    group('close', () {
      test('cubit closes without error', () async {
        final cubit = buildCubit();
        await expectLater(cubit.close(), completes);
      });
    });
  });
}
