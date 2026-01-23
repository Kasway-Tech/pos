import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1e6b4f),
      surfaceTint: Color(0xff1e6b4f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa7f2cf),
      onPrimaryContainer: Color(0xff00513a),
      secondary: Color(0xff4c6358),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcfe9da),
      onSecondaryContainer: Color(0xff354b41),
      tertiary: Color(0xff3e6374),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc1e8fc),
      onTertiaryContainer: Color(0xff254b5b),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff171d1a),
      onSurfaceVariant: Color(0xff404944),
      outline: Color(0xff707973),
      outlineVariant: Color(0xffbfc9c2),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8cd5b4),
      primaryFixed: Color(0xffa7f2cf),
      onPrimaryFixed: Color(0xff002115),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff00513a),
      secondaryFixed: Color(0xffcfe9da),
      onSecondaryFixed: Color(0xff092017),
      secondaryFixedDim: Color(0xffb3ccbe),
      onSecondaryFixedVariant: Color(0xff354b41),
      tertiaryFixed: Color(0xffc1e8fc),
      onTertiaryFixed: Color(0xff001f2a),
      tertiaryFixedDim: Color(0xffa6ccdf),
      onTertiaryFixedVariant: Color(0xff254b5b),
      surfaceDim: Color(0xffd6dbd6),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5ef),
      surfaceContainer: Color(0xffeaefea),
      surfaceContainerHigh: Color(0xffe4eae4),
      surfaceContainerHighest: Color(0xffdee4de),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003f2c),
      surfaceTint: Color(0xff1e6b4f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff307a5d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff253b31),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b7266),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff113b4a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4d7283),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff0d120f),
      onSurfaceVariant: Color(0xff2f3833),
      outline: Color(0xff4b554f),
      outlineVariant: Color(0xff666f69),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8cd5b4),
      primaryFixed: Color(0xff307a5d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0e6146),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5b7266),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff435a4e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4d7283),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff345a6a),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c8c3),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5ef),
      surfaceContainer: Color(0xffe4eae4),
      surfaceContainerHigh: Color(0xffd8ded9),
      surfaceContainerHighest: Color(0xffcdd3ce),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003323),
      surfaceTint: Color(0xff1e6b4f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00543c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1b3027),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff374e43),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff02303f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff274e5e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e29),
      outlineVariant: Color(0xff424b46),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8cd5b4),
      primaryFixed: Color(0xff00543c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003b29),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff374e43),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff21372d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff274e5e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff0c3746),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4bab5),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2ed),
      surfaceContainer: Color(0xffdee4de),
      surfaceContainerHigh: Color(0xffd0d6d0),
      surfaceContainerHighest: Color(0xffc2c8c3),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8cd5b4),
      surfaceTint: Color(0xff8cd5b4),
      onPrimary: Color(0xff003827),
      primaryContainer: Color(0xff00513a),
      onPrimaryContainer: Color(0xffa7f2cf),
      secondary: Color(0xffb3ccbe),
      onSecondary: Color(0xff1f352b),
      secondaryContainer: Color(0xff354b41),
      onSecondaryContainer: Color(0xffcfe9da),
      tertiary: Color(0xffa6ccdf),
      onTertiary: Color(0xff083544),
      tertiaryContainer: Color(0xff254b5b),
      onTertiaryContainer: Color(0xffc1e8fc),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffdee4de),
      onSurfaceVariant: Color(0xffbfc9c2),
      outline: Color(0xff8a938d),
      outlineVariant: Color(0xff404944),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff1e6b4f),
      primaryFixed: Color(0xffa7f2cf),
      onPrimaryFixed: Color(0xff002115),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff00513a),
      secondaryFixed: Color(0xffcfe9da),
      onSecondaryFixed: Color(0xff092017),
      secondaryFixedDim: Color(0xffb3ccbe),
      onSecondaryFixedVariant: Color(0xff354b41),
      tertiaryFixed: Color(0xffc1e8fc),
      onTertiaryFixed: Color(0xff001f2a),
      tertiaryFixedDim: Color(0xffa6ccdf),
      onTertiaryFixedVariant: Color(0xff254b5b),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff353b37),
      surfaceContainerLowest: Color(0xff0a0f0d),
      surfaceContainerLow: Color(0xff171d1a),
      surfaceContainer: Color(0xff1b211e),
      surfaceContainerHigh: Color(0xff252b28),
      surfaceContainerHighest: Color(0xff303633),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa1ecc9),
      surfaceTint: Color(0xff8cd5b4),
      onPrimary: Color(0xff002c1e),
      primaryContainer: Color(0xff569e80),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc9e2d4),
      onSecondary: Color(0xff142a20),
      secondaryContainer: Color(0xff7e9689),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffbbe2f6),
      onTertiary: Color(0xff002937),
      tertiaryContainer: Color(0xff7096a8),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd5dfd7),
      outline: Color(0xffabb4ad),
      outlineVariant: Color(0xff89938c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff00533b),
      primaryFixed: Color(0xffa7f2cf),
      onPrimaryFixed: Color(0xff00150c),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff003f2c),
      secondaryFixed: Color(0xffcfe9da),
      onSecondaryFixed: Color(0xff01150d),
      secondaryFixedDim: Color(0xffb3ccbe),
      onSecondaryFixedVariant: Color(0xff253b31),
      tertiaryFixed: Color(0xffc1e8fc),
      onTertiaryFixed: Color(0xff00131c),
      tertiaryFixedDim: Color(0xffa6ccdf),
      onTertiaryFixedVariant: Color(0xff113b4a),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff404642),
      surfaceContainerLowest: Color(0xff040806),
      surfaceContainerLow: Color(0xff191f1c),
      surfaceContainer: Color(0xff232926),
      surfaceContainerHigh: Color(0xff2e3430),
      surfaceContainerHighest: Color(0xff393f3b),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb8ffdd),
      surfaceTint: Color(0xff8cd5b4),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff88d1b0),
      onPrimaryContainer: Color(0xff000e07),
      secondary: Color(0xffdcf6e7),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffafc8ba),
      onSecondaryContainer: Color(0xff000e07),
      tertiary: Color(0xffdef3ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa2c8db),
      onTertiaryContainer: Color(0xff000d14),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe9f2eb),
      outlineVariant: Color(0xffbbc5be),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff00533b),
      primaryFixed: Color(0xffa7f2cf),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff00150c),
      secondaryFixed: Color(0xffcfe9da),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb3ccbe),
      onSecondaryFixedVariant: Color(0xff01150d),
      tertiaryFixed: Color(0xffc1e8fc),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa6ccdf),
      onTertiaryFixedVariant: Color(0xff00131c),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff4b514d),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b211e),
      surfaceContainer: Color(0xff2c322e),
      surfaceContainerHigh: Color(0xff373d39),
      surfaceContainerHighest: Color(0xff424844),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
