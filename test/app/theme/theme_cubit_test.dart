import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/theme/theme_cubit.dart';
import 'package:kasway/app/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is correct', () async {
      final cubit = ThemeCubit();
      // Allow async initial load to complete
      await Future.delayed(Duration.zero);
      expect(cubit.state, const ThemeState());
    });

    blocTest<ThemeCubit, ThemeState>(
      'emits new state when seed color is set',
      build: () => ThemeCubit(),
      act: (cubit) => cubit.setSeedColor(Colors.red),
      expect: () => contains(
        isA<ThemeState>().having((s) => s.seedColor, 'seedColor', Colors.red),
      ),
    );

    blocTest<ThemeCubit, ThemeState>(
      'emits new state when theme mode is set',
      build: () => ThemeCubit(),
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => contains(
        isA<ThemeState>().having(
          (s) => s.themeMode,
          'themeMode',
          ThemeMode.dark,
        ),
      ),
    );
  });
}
