import 'package:flutter/material.dart';

class AppTheme {
  // 1. Brand Identity Colors
  // Wrapper color: Used for background
  static const Color _brandBackground = Color(0xFF18181B);

  // Logo color: Used for Primary interactions (Buttons, FABs, Toggles)
  static const Color _brandPrimary = Color(0xFF62AA8B);

  // Calculated Surface: A slightly lighter tone of the wrapper for Cards/AppBar
  // (Lifted from #18181B -> #27272A to create depth)
  // PRESERVED YOUR CHANGE HERE:
  static const Color _brandSurface = Color.fromARGB(255, 32, 32, 34);
  static const Color _brandSurfaceLighter = Color.fromARGB(255, 50, 50, 53);

  // Text Color: Slightly off-white (#F2F2F2) to reduce eye strain on dark backgrounds
  static const Color _brandText = Color(0xFFF2F2F2);
  static const Color _brandTextSecondary = Color(0xFFA1A1AA); // Muted text

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 2. Core Color Scheme
      scaffoldBackgroundColor: _brandBackground,
      colorScheme: const ColorScheme.dark(
        primary: _brandPrimary,
        onPrimary: _brandBackground, // Text inside primary buttons
        secondary: _brandPrimary,

        // UPDATED: 'surface' is the new base/background in M3
        surface: _brandBackground,
        onSurface: _brandText,

        // ADDED: 'surfaceContainer' holds the lighter color for cards/modals
        // This replaces the old behavior of 'surface' being the card color
        surfaceContainer: _brandSurface,
        outline: _brandSurfaceLighter,
        outlineVariant: _brandSurfaceLighter,

        // REMOVED: background & onBackground (Deprecated)
        error: Color(0xFFCF6679),
      ),

      // 3. Component Themes

      // AppBar: Uses the lighter surface tone
      appBarTheme: const AppBarTheme(
        backgroundColor: _brandSurface,
        foregroundColor: _brandText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // Cards: Uses the lighter surface tone
      // FIXED: Changed CardThemeData -> CardTheme
      cardTheme: CardThemeData(
        color: _brandSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _brandPrimary,
        foregroundColor: _brandBackground,
      ),

      // Text Theme: Applied globally
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _brandText),
        displayMedium: TextStyle(color: _brandText),
        bodyLarge: TextStyle(color: _brandText),
        bodyMedium: TextStyle(color: _brandText),
        labelLarge: TextStyle(color: _brandText),
      ).apply(bodyColor: _brandText, displayColor: _brandText),

      // Inputs/Text Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _brandSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: _brandTextSecondary),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: _brandSurfaceLighter,
        thickness: 1,
      ),
    );
  }
}
