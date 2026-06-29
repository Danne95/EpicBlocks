import 'package:flutter/material.dart';

/// Material 3 theme configuration for EpicBlocks.
class AppTheme {
  const AppTheme._();

  /// Creates the default light theme.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
    );

    return _themeFromColorScheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F7F4),
    );
  }

  /// Creates the default dark theme.
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF14B8A6),
      brightness: Brightness.dark,
    );

    return _themeFromColorScheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF111827),
    );
  }

  static ThemeData _themeFromColorScheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
