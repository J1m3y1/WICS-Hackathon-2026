import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0B1020);
  static const Color card = Color(0xFF151B2F);
  static const Color primary = Color(0xFF7C4DFF);
  static const Color secondary = Color(0xFF4DD0E1);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B7C3);
  static const Color progressBackground = Color(0xFF2A314A);

  static const Color chipBackground = Color(0xFF1A2238);
  static const Color border = Color(0xFF2C3550);
}

class AppTextStyles {
  static const TextStyle pageTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle subText = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heroLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white70,
  );

  static const TextStyle heroTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle chipText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
