import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The [AppTheme] defines light and dark themes for the app.
abstract final class AppTheme {
  static const String? fontFamily = null;

  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: Color(0xFFF2138E),
      primaryContainer: Color(0xFFFFD9F0),
      secondary: Color(0xFF3605EB),
      secondaryContainer: Color(0xFFE4D9FF),
      tertiary: Color(0xFF004881),
      tertiaryContainer: Color(0xFFD0E4FF),
      appBarColor: Color(0xFFFFFFFF),
      error: Color(0xFFE84118),
      errorContainer: Color(0xFFFFDAD6),
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      fabUseShape: true,
      fabRadius: 48.0,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    textTheme: _textTheme,
  );

  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xFFF2138E),
      primaryContainer: Color(0xFFD20C79),
      primaryLightRef: Color(0xFFF2138E),
      secondary: Color(0xFFB9A7FD),
      secondaryContainer: Color(0xFF3605EB),
      secondaryLightRef: Color(0xFF3605EB),
      tertiary: Color(0xFFA4C8FF),
      tertiaryContainer: Color(0xFF004881),
      tertiaryLightRef: Color(0xFF004881),
      appBarColor: Color(0xFF120B1B),
      error: Color(0xFFFFB4AB),
      errorContainer: Color(0xFF93000A),
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      fabUseShape: true,
      fabRadius: 48.0,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    textTheme: _textThemeDark,
  );

  static TextTheme get _textTheme => TextTheme(
        displayLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w300),
        displayMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        displaySmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        headlineLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        headlineMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        headlineSmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        titleLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        titleSmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        bodyLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        bodyMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        bodySmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        labelLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        labelMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        labelSmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      );

  static TextTheme get _textThemeDark => TextTheme(
        displayLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w300),
        displayMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        displaySmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        headlineLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        headlineMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        headlineSmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        titleLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        titleSmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        bodyLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        bodyMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        bodySmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400),
        labelLarge:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        labelMedium:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        labelSmall:
            TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      );
}