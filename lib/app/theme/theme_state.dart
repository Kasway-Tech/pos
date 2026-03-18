import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  static const Color defaultSeedColor = Color(0xff1e6b4f); // Brand green

  const ThemeState({
    this.seedColor = defaultSeedColor,
    this.themeMode = ThemeMode.system,
  });

  final Color seedColor;
  final ThemeMode themeMode;

  ThemeState copyWith({Color? seedColor, ThemeMode? themeMode}) {
    return ThemeState(
      seedColor: seedColor ?? this.seedColor,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [seedColor, themeMode];
}
