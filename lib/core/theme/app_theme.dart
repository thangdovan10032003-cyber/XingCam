import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        background: AppColors.background,
        error: Color(0xFFCF6679),
      ),
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.textPrimary,
        overlayColor: AppColors.accent.withOpacity(0.1),
        trackHeight: 2,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgRadius,
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary),
      ),
    );
  }
}
