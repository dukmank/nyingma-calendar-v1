import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const Color maroon = Color(0xFF8B0000);
  static const Color maroonLight = Color(0xFFAD2831);
  static const Color maroonDark = Color(0xFF5C0000);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8CC6E);
  static const Color goldDark = Color(0xFFB8960C);
  static const Color navy = Color(0xFF1A1A3C);
  static const Color navyLight = Color(0xFF2D2D5E);
  static const Color cream = Color(0xFFF5E6D3);
  static const Color creamLight = Color(0xFFFAF3EB);

  // Semantic colors
  static const Color excellent = Color(0xFF2E7D32);
  static const Color good = Color(0xFF558B2F);
  static const Color neutral = Color(0xFF757575);
  static const Color avoid = Color(0xFFE65100);
  static const Color avoidStrongly = Color(0xFFC62828);

  // Lineage colors
  static const Color allNyingma = Color(0xFF8B0000);
  static const Color dudjom = Color(0xFF1565C0);
  static const Color mindrolling = Color(0xFF2E7D32);
  static const Color dorjeDrak = Color(0xFFE65100);
  static const Color kathok = Color(0xFF6A1B9A);
  static const Color palyul = Color(0xFFC62828);
  static const Color shechen = Color(0xFF00838F);
  static const Color dzogchen = Color(0xFFAD1457);

  // Dark mode
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF252540);
  static const Color darkText = Color(0xFFE8E8F0);
  static const Color darkTextSecondary = Color(0xFFA0A0B8);

  // Light mode
  static const Color lightBg = Color(0xFFFAF3EB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5E6D3);
  static const Color lightText = Color(0xFF1A1A3C);
  static const Color lightTextSecondary = Color(0xFF5C5C7A);

  static Color getLineageColor(String lineage) {
    switch (lineage.toLowerCase()) {
      case 'dudjom':
      case 'dudjom tersar':
        return dudjom;
      case 'mindrolling':
        return mindrolling;
      case 'dorje drak':
      case 'dorje-drak':
        return dorjeDrak;
      case 'kathok':
        return kathok;
      case 'palyul':
        return palyul;
      case 'shechen':
        return shechen;
      case 'dzogchen':
        return dzogchen;
      default:
        return allNyingma;
    }
  }

  static Color getRecommendationColor(String rec) {
    final r = rec.toLowerCase();
    if (r.contains('excellent') || r.contains('best')) return excellent;
    if (r.contains('very good') || r.contains('good')) return good;
    if (r.contains('avoid!') || r.contains('avoid strongly')) return avoidStrongly;
    if (r.contains('avoid')) return avoid;
    return neutral;
  }
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.maroon,
      colorScheme: const ColorScheme.light(
        primary: AppColors.maroon,
        secondary: AppColors.gold,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: AppColors.navy,
        onSurface: AppColors.lightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: AppColors.navy.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.navy),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.navy),
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.navy),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.navy),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navy),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.navy),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.lightText),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.lightText),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.maroon),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.maroon,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.cream.withOpacity(0.5),
        thickness: 1,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.maroon,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.maroonLight,
        secondary: AppColors.gold,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: AppColors.darkText,
        onSurface: AppColors.darkText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroonLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.darkText),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkText),
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.darkText),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.darkText),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkText),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkText),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.darkText),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.darkText),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.darkTextSecondary),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.goldLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.goldLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkCard.withOpacity(0.5),
        thickness: 1,
      ),
    );
  }
}
