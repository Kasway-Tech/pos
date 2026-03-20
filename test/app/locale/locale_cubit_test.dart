import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/locale/locale_cubit.dart';
import 'package:kasway/app/locale/locale_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppLanguage', () {
    const en = AppLanguage(
      code: 'en',
      countryCode: 'US',
      displayName: 'English',
      nativeName: 'English',
    );

    test('locale returns Locale with language code', () {
      expect(en.locale, const Locale('en'));
    });

    test('equality is based on code only', () {
      const en2 = AppLanguage(
        code: 'en',
        countryCode: 'GB', // different country
        displayName: 'English (GB)',
        nativeName: 'English',
      );
      expect(en, equals(en2));
    });

    test('different language codes are not equal', () {
      const id = AppLanguage(
        code: 'id',
        countryCode: 'ID',
        displayName: 'Indonesian',
        nativeName: 'Bahasa Indonesia',
      );
      expect(en, isNot(equals(id)));
    });
  });

  group('LocaleState', () {
    group('supportedLanguages', () {
      test('contains 6 languages', () {
        expect(LocaleState.supportedLanguages.length, 6);
      });

      test('contains English, Indonesian, Malay, Chinese, Japanese, Korean', () {
        final codes = LocaleState.supportedLanguages.map((l) => l.code).toSet();
        expect(codes, containsAll(['en', 'id', 'ms', 'zh', 'ja', 'ko']));
      });
    });

    group('defaultLanguage', () {
      test('is English', () {
        expect(LocaleState.defaultLanguage.code, 'en');
      });
    });

    group('default state', () {
      test('language defaults to English', () {
        expect(const LocaleState().language.code, 'en');
      });

      test('locale returns en Locale', () {
        expect(const LocaleState().locale, const Locale('en'));
      });
    });

    group('equality', () {
      test('two default states are equal', () {
        expect(const LocaleState(), equals(const LocaleState()));
      });

      test('states with different languages are not equal', () {
        const id = AppLanguage(
          code: 'id',
          countryCode: 'ID',
          displayName: 'Indonesian',
          nativeName: 'Bahasa Indonesia',
        );
        expect(
          const LocaleState(),
          isNot(equals(const LocaleState(language: id))),
        );
      });
    });
  });

  group('LocaleCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('initial load — no persisted value', () {
      blocTest<LocaleCubit, LocaleState>(
        'does not emit when no language is persisted (default stays)',
        build: () => LocaleCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [],
      );

      test('initial state is English', () {
        final cubit = LocaleCubit();
        expect(cubit.state.language.code, 'en');
        cubit.close();
      });
    });

    group('initial load — persisted language restored', () {
      blocTest<LocaleCubit, LocaleState>(
        'emits Indonesian when id is persisted',
        setUp: () {
          SharedPreferences.setMockInitialValues({'app_language_code': 'id'});
        },
        build: () => LocaleCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<LocaleState>().having((s) => s.language.code, 'code', 'id'),
        ],
      );

      blocTest<LocaleCubit, LocaleState>(
        'emits Japanese when ja is persisted',
        setUp: () {
          SharedPreferences.setMockInitialValues({'app_language_code': 'ja'});
        },
        build: () => LocaleCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<LocaleState>().having((s) => s.language.code, 'code', 'ja'),
        ],
      );

      blocTest<LocaleCubit, LocaleState>(
        'falls back to English when unknown language code is persisted',
        setUp: () {
          SharedPreferences.setMockInitialValues({'app_language_code': 'xx'});
        },
        build: () => LocaleCubit(),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          isA<LocaleState>().having((s) => s.language.code, 'code', 'en'),
        ],
      );
    });

    group('setLanguage', () {
      const idLanguage = AppLanguage(
        code: 'id',
        countryCode: 'ID',
        displayName: 'Indonesian',
        nativeName: 'Bahasa Indonesia',
      );

      blocTest<LocaleCubit, LocaleState>(
        'emits state with new language and persists to prefs',
        build: () => LocaleCubit(),
        act: (cubit) => cubit.setLanguage(idLanguage),
        expect: () => [
          isA<LocaleState>().having((s) => s.language.code, 'code', 'id'),
        ],
        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('app_language_code'), 'id');
        },
      );

      blocTest<LocaleCubit, LocaleState>(
        'emits correct locale for new language',
        build: () => LocaleCubit(),
        act: (cubit) => cubit.setLanguage(idLanguage),
        expect: () => [
          isA<LocaleState>().having(
            (s) => s.locale,
            'locale',
            const Locale('id'),
          ),
        ],
      );

      blocTest<LocaleCubit, LocaleState>(
        'sets all 6 supported languages without error',
        build: () => LocaleCubit(),
        act: (cubit) async {
          for (final lang in LocaleState.supportedLanguages) {
            await cubit.setLanguage(lang);
          }
        },
        verify: (cubit) {
          expect(cubit.state.language.code, 'ko'); // last in list
        },
      );
    });

    group('close', () {
      test('cubit closes without error', () async {
        final cubit = LocaleCubit();
        await expectLater(cubit.close(), completes);
      });
    });
  });
}
