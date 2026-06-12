import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Primary - Corn Yellow
  static const Color primary = Color(0xFFF5C518);
  static const Color primaryDark = Color(0xFFD4A800);
  static const Color primaryLight = Color(0xFFFFF0A0);

  // Secondary - Leaf Green
  static const Color secondary = Color(0xFF2D6A4F);
  static const Color secondaryLight = Color(0xFF52B788);
  static const Color secondaryPale = Color(0xFFD8F3DC);

  // Light Mode
  static const Color background = Color(0xFFFFF8E7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0E8);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);
  static const Color cardShadow = Color(0x0F1A1A2E);

  // Dark Mode
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1C1F26);
  static const Color darkSurfaceVariant = Color(0xFF252830);
  static const Color darkTextPrimary = Color(0xFFF0EDD8);
  static const Color darkTextSecondary = Color(0xFFAAADB5);
  static const Color darkTextHint = Color(0xFF6B6E76);
  static const Color darkDivider = Color(0xFF2E3039);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.poppins(
      fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle get displayMedium => GoogleFonts.poppins(
      fontSize: 24, fontWeight: FontWeight.w700, height: 1.3);
  static TextStyle get headlineLarge => GoogleFonts.poppins(
      fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get headlineMedium => GoogleFonts.poppins(
      fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get titleLarge => GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w600, height: 1.5);
  static TextStyle get titleMedium => GoogleFonts.poppins(
      fontSize: 14, fontWeight: FontWeight.w500, height: 1.5);
  static TextStyle get bodyLarge => GoogleFonts.poppins(
      fontSize: 14, fontWeight: FontWeight.w400, height: 1.6);
  static TextStyle get bodyMedium => GoogleFonts.poppins(
      fontSize: 13, fontWeight: FontWeight.w400, height: 1.6);
  static TextStyle get labelLarge => GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.5);
  static TextStyle get labelSmall => GoogleFonts.poppins(
      fontSize: 10, fontWeight: FontWeight.w500, height: 1.4);
  static TextStyle get priceStyle => GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary);
  static TextStyle get priceLarge => GoogleFonts.poppins(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.secondary);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          background: AppColors.background,
          surface: AppColors.surface,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerColor: AppColors.divider,
        cardColor: AppColors.surface,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          primary: AppColors.primary,
          secondary: AppColors.secondaryLight,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.darkBackground,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerColor: AppColors.darkDivider,
        cardColor: AppColors.darkSurface,
      );
}
