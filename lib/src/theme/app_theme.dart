import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF003461);
  static const Color primaryContainer = Color(0xFF004B87);
  static const Color secondary = Color(0xFF466649);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF424750);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(color: onSurface, fontWeight: FontWeight.w800),
        displayMedium: GoogleFonts.plusJakartaSans(color: onSurface, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(color: onSurfaceVariant),
        bodyMedium: GoogleFonts.inter(color: onSurfaceVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }
}