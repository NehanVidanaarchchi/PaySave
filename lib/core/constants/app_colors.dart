import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C4DFF);
  static const Color primaryDark = Color(0xFF17124A);
  static const Color secondary = Color(0xFF8B7CFF);

  static const Color background = Color(0xFFF7F6FF);
  static const Color softLavender = Color(0xFFEDEBFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E5F5);

  static const Color textPrimary = Color(0xFF15152F);
  static const Color textSecondary = Color(0xFF7C7D91);
  static const Color textLight = Color(0xFFA7A8BA);

  static const Color success = Color(0xFF26B56E);
  static const Color warning = Color(0xFFFFB84D);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4BA3FF);

  static const Color rent = Color(0xFFFF6B6B);
  static const Color bills = Color(0xFFFFB84D);
  static const Color savings = Color(0xFF26B56E);
  static const Color expenses = Color(0xFF9B7BFF);

  static const Color darkBackground = Color(0xFF080A12);
  static const Color darkCard = Color(0xFF111522);
  static const Color darkBorder = Color(0xFF1D2333);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7D5CFF), Color(0xFF5638D8)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8F7FF), Color(0xFFE9E7FF)],
  );

  static const LinearGradient cardPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7A5CFF), Color(0xFF4A32C9)],
  );
}
