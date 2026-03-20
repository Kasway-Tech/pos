import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(PreferenceKeys.themeSeedColor);
    final themeModeIndex = prefs.getInt(PreferenceKeys.themeMode);

    emit(
      ThemeState(
        seedColor: colorValue != null
            ? Color(colorValue)
            : ThemeState.defaultSeedColor,
        themeMode: themeModeIndex != null
            ? ThemeMode.values[themeModeIndex]
            : ThemeMode.dark,
      ),
    );
  }

  Future<void> resetSeedColor() => setSeedColor(ThemeState.defaultSeedColor);

  Future<void> setSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferenceKeys.themeSeedColor, color.toARGB32());
    emit(state.copyWith(seedColor: color));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferenceKeys.themeMode, mode.index);
    emit(state.copyWith(themeMode: mode));
  }
}
