import 'package:flutter/material.dart';

class AppTheme {
  static const red = Color(0xFFE53935);
  static const ink = Color(0xFF0B0B0C);
  static const surface = Color(0xFF1E1E21);
  static const backgroundSecondary = Color(0xFF151517);
  static const lightCard = Color(0xFFE5E5E7);
  static const border = Color(0xFF333337);
  static const muted = Color(0xFFA7A7AD);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: red,
      brightness: brightness,
      surface: isDark ? surface : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? ink : const Color(0xFFF7F7F8),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? ink : Colors.white,
        foregroundColor: isDark ? Colors.white : ink,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        ),
      ),
      textTheme: TextTheme(
        titleLarge: const TextStyle(fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : ink,
        ),
        bodyMedium: TextStyle(color: isDark ? muted : const Color(0xFF55555B)),
      ),
    );
  }
}
