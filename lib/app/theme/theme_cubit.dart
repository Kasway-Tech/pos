import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  static const String _seedColorKey = 'theme_seed_color';
  static const String _themeModeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_seedColorKey);
    final themeModeIndex = prefs.getInt(_themeModeKey);

    emit(
      ThemeState(
        seedColor: colorValue != null
            ? Color(colorValue)
            : ThemeState.defaultSeedColor,
        themeMode: themeModeIndex != null
            ? ThemeMode.values[themeModeIndex]
            : ThemeMode.system,
      ),
    );
  }

  Future<void> resetSeedColor() => setSeedColor(ThemeState.defaultSeedColor);

  Future<void> setSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
    emit(state.copyWith(seedColor: color));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    emit(state.copyWith(themeMode: mode));
  }
}
