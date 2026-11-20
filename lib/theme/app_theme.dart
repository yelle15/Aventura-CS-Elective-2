import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const red = Color(0xFFE53935);
  static const crimson = Color(0xFFB0102A);
  static const ember = Color(0xFFFF6B4A);
  static const wine = Color(0xFF4A0710);
  static const night = Color(0xFF14080A);
  static const ink = Color(0xFF0B0B0C);
  static const surface = Color(0xFF1E1E21);
  static const backgroundSecondary = Color(0xFF151517);
  static const lightCard = Color(0xFFE5E5E7);
  static const lightPanel = Color(0xFFF1F1F3);
  static const border = Color(0xFF333337);
  static const lightBorder = Color(0xFFD5D5D9);
  static const muted = Color(0xFFA7A7AD);
  static const success = Color(0xFF2E7D32);
  static const rating = Color(0xFFFFB300);
  static const neutral = Color(0xFF757575);
  static const onAccent = Color(0xFFFFFFFF);

  static const redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [red, crimson],
  );

  static const nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [wine, night],
  );

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color outline(BuildContext context) =>
      isDark(context) ? border : lightBorder;

  static Color panel(BuildContext context) =>
      isDark(context) ? surface : Colors.white;

  static List<BoxShadow> softShadow(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withAlpha(isDark(context) ? 110 : 22),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> redGlow({int alpha = 70}) => [
        BoxShadow(
          color: red.withAlpha(alpha),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];

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

  static OutlineInputBorder _field(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }

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
    final softBorder = isDark ? border : lightBorder;
    final background = isDark ? ink : const Color(0xFFF7F7F8);
    final panelColor = isDark ? surface : Colors.white;
    final buttonText = GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: isDark ? Colors.white : ink,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: softBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? backgroundSecondary : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: _field(softBorder),
        enabledBorder: _field(softBorder),
        disabledBorder: _field(softBorder.withAlpha(110)),
        focusedBorder: _field(red, 1.6),
        errorBorder: _field(scheme.error),
        focusedErrorBorder: _field(scheme.error, 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : ink,
          side: BorderSide(color: softBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: red,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panelColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: panelColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: softBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A2A2E) : ink,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: panelColor,
        selectedColor: red,
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
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: red),
      dividerTheme: DividerThemeData(color: softBorder),
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
