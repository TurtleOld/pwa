import 'package:flutter/material.dart';

class AppColors {
  // Modern primary colors with better contrast
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald-400
  static const Color secondaryDark = Color(0xFF059669); // Emerald-600

  // Status colors with modern palette
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color danger = Color(0xFFEF4444); // Red-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF8F9FA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE9ECEF);
  static const Color gray300 = Color(0xFFDEE2E6);
  static const Color gray400 = Color(0xFFCED4DA);
  static const Color gray500 = Color(0xFFADB5BD);
  static const Color gray600 = Color(0xFF6C757D);
  static const Color gray700 = Color(0xFF495057);
  static const Color gray800 = Color(0xFF343A40);
  static const Color gray900 = Color(0xFF212529);

  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFB5B5B5);
  static const Color textLight = Color(0xFFF5F5F5);

  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF8F9FA);
  static const Color bgTertiary = Color(0xFFE9ECEF);
  static const Color bgDark = Color(0xFF121212);
  static const Color bgDarkSecondary = Color(0xFF2C313A);
  static const Color bgDarkTertiary = Color(0xFF23272F);

  static const Color borderLight = Color(0xFFDBDBDB);
  static const Color borderMedium = Color(0xFFB5B5B5);
  static const Color borderDark = Color(0xFF4A4A4A);

  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB5B5B5);
  static const Color darkTextMuted = Color(0xFF7A7A7A);
  static const Color darkBgPrimary = Color(
    0xFF0F0F23,
  ); // Modern dark background
  static const Color darkBgSecondary = Color(
    0xFF1A1A2E,
  ); // Slightly lighter dark
  static const Color darkBgTertiary = Color(0xFF16213E); // Even lighter dark
  static const Color darkBorderLight = Color(0xFF2D3748);
  static const Color darkBorderMedium = Color(0xFF4A5568);
  static const Color darkBorderDark = Color(0xFF718096);

  // Modern shadow colors
  static const Color shadowLight = Color(0x0A000000); // 4% opacity
  static const Color shadowMedium = Color(0x14000000); // 8% opacity
  static const Color shadowDark = Color(0x1F000000); // 12% opacity
  static const Color shadowColored = Color(0x1A6366F1); // Primary color shadow

  // Glass morphism colors
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x20000000);
  static const Color glassBorder = Color(0x30FFFFFF);

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1), // Indigo-500
    Color(0xFF8B5CF6), // Violet-500
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF10B981), // Emerald-500
    Color(0xFF06B6D4), // Cyan-500
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFF8FAFC), // Slate-50
    Color(0xFFF1F5F9), // Slate-100
  ];

  static const List<Color> darkBackgroundGradient = [
    Color(0xFF0F0F23), // Dark primary
    Color(0xFF1A1A2E), // Dark secondary
  ];
}
