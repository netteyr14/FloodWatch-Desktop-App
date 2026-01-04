// lib/app_theme.dart
import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  static void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class AppTheme {
  /* =========================================================
     COLOR CONSTANTS
  ========================================================= */

  static const Color _brandGreen = Color(0xFF7EA531);

  // Light mode background system
  static const Color _lightBg = Color(0xFFF4F4F4);
  static const Color _lightCard = Color(0xFFFFFDEB);

  // Dark mode background system (now a bit darker / less bright)
  static const Color _darkBg = Color(0xFF111210);        // page bg
  static const Color _darkSurface = Color(0xFF181A15);   // big panels
  static const Color _darkCard = Color(0xFF202219);      // inner cards
  static const Color _darkHeaderStart = Color(0xFF1A2211);
  static const Color _darkHeaderEnd = Color(0xFF0A0C07);

  static const Color _darkText = Color(0xFFE6E7E1);
  static const Color _darkTextSecondary = Color(0xFFB7B9B0);

  /* =========================================================
     LIGHT THEME
  ========================================================= */

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,
    scaffoldBackgroundColor: _lightBg,
    cardColor: _lightCard,
    dividerColor: Colors.black12,
    iconTheme: const IconThemeData(color: Colors.black87),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      titleMedium: TextStyle(color: Colors.black87),
      titleSmall: TextStyle(
        color: Colors.black87,
        fontSize: 18,   // <--- increase section title size
        fontWeight: FontWeight.w700,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandGreen,
      primary: _brandGreen,
      background: _lightBg,
      surface: _lightCard,
      brightness: Brightness.light,
    ),
  );

  /* =========================================================
     DARK THEME
  ========================================================= */

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,

    scaffoldBackgroundColor: _darkBg,
    cardColor: _darkCard,
    canvasColor: _darkSurface,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _brandGreen,
      secondary: Color(0xFF556533),
      surface: _darkSurface,
      background: _darkBg,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: _darkText,
      onBackground: _darkText,
      error: Colors.red,
      onError: Colors.white,
    ),

    dividerColor: Color(0xFF34352F),

    iconTheme: const IconThemeData(color: _darkTextSecondary),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: _darkText),
      bodyLarge: TextStyle(color: _darkText),
      titleMedium: TextStyle(color: _darkText),
      titleLarge: TextStyle(color: _darkText),

      titleSmall: TextStyle(
        color: _darkText,
        fontSize: 18,   // <--- same size for dark mode
        fontWeight: FontWeight.w700,
      ),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: _darkTextSecondary,
      textColor: _darkText,
    ),
  );

  /* =========================================================
     CUSTOM HELPERS (for header & sidebar)
  ========================================================= */

  static LinearGradient darkHeaderGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _darkHeaderStart,
      _darkHeaderEnd,
    ],
  );

  // Sidebar colors – now clearly darker in dark mode
  static const Color darkSidebar = Color.fromARGB(255, 39, 41, 27);
  static const Color darkSidebarActive = Color(0xFF3B4A23);
  static const Color darkSidebarText = _darkTextSecondary;

}
