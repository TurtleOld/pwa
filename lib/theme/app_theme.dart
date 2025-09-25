import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgSecondary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        shadowColor: AppColors.shadowLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: AppColors.shadowColored,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgSecondary,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        shadowColor: AppColors.shadowDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBgSecondary,
        elevation: 0,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextMuted),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: AppColors.shadowColored,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
      ),
    );
  }
}

// Modern shadow utilities
class ModernShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 25,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.shadowColored,
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonHover = [
    BoxShadow(
      color: AppColors.shadowColored,
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 30,
      offset: Offset(0, 15),
      spreadRadius: 0,
    ),
  ];
}

// Glass morphism utilities
class GlassMorphism {
  static BoxDecoration light({double borderRadius = 16, double opacity = 0.1}) {
    return BoxDecoration(
      color: AppColors.glassLight.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.glassBorder.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  static BoxDecoration dark({double borderRadius = 16, double opacity = 0.1}) {
    return BoxDecoration(
      color: AppColors.glassDark.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.glassBorder.withOpacity(0.1),
        width: 1,
      ),
    );
  }
}
