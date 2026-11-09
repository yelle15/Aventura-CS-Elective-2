import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const red = Color(0xFFE53935);
  static const ink = Color(0xFF0B0B0C);
  static const surface = Color(0xFF1E1E21);
  static const backgroundSecondary = Color(0xFF151517);
  static const lightCard = Color(0xFFE5E5E7);
  static const border = Color(0xFF333337);
  static const muted = Color(0xFFA7A7AD);
  static const success = Color(0xFF2E7D32);
  static const rating = Color(0xFFFFB300);
  static const neutral = Color(0xFF757575);
  static const onAccent = Color(0xFFFFFFFF);

  static TextStyle display({double fontSize = 40, Color? color}) {
    return GoogleFonts.oswald(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: 0.5,
      color: color,
    );
  }

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: red,
      brightness: brightness,
      surface: isDark ? surface : Colors.white,
    ).copyWith(primary: red, onPrimary: Colors.white);
    final baseText = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    final softBorder = isDark ? border : const Color(0xFFD5D5D9);
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
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: softBorder)),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: red,
        inactiveTrackColor: softBorder,
        thumbColor: red,
        overlayColor: red.withAlpha(40),
      ),
      textTheme: baseText.copyWith(
        titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : ink,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: isDark ? muted : const Color(0xFF55555B),
        ),
      ),
    );
  }
}
