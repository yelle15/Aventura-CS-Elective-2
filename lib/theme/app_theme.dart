import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color pokedexRed = Color(0xFFEE1515);
  static const Color blue = Color(0xFF3466AF);
  static const Color navy = Color(0xFF21386E);
  static const Color midnight = Color(0xFF1D2C5E);
  static const Color yellow = Color(0xFFFFCB05);
  static const Color gold = Color(0xFFC7A008);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.pokedexRed,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.pokedexRed,
      onPrimary: Colors.white,
      secondary: AppColors.blue,
      tertiary: AppColors.yellow,
    );

    final pokemonFont = GoogleFonts.pixelifySans();

    return ThemeData(
      colorScheme: scheme,
      fontFamily: pokemonFont.fontFamily,
      textTheme: GoogleFonts.pixelifySansTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF141E38) : AppColors.yellow,
        foregroundColor: isDark ? Colors.white : AppColors.midnight,
        centerTitle: true,
        elevation: 4,
        shadowColor: const Color(0x66000000),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 4,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pokedexRed,
          foregroundColor: Colors.white,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.pokedexRed,
      ),
    );
  }

  static LinearGradient backgroundFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.midnight, AppColors.navy, Color(0xFF2B4A8A)],
        stops: [0, 0.55, 1],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5B86C6), Color(0xFFDCE6F5), Color(0xFFFFE78A)],
      stops: [0, 0.55, 1],
    );
  }
}
