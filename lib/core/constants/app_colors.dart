import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color background = Color(0xff000000);
  static const Color card = Color(0xff111111);
  static const Color cardLight = Color(0xff181818);
  static const Color textPrimary = Color(0xffffffff);
  static const Color textSecondary = Color(0xffA1A1A1);
  static const Color textLight = Color(0xff666666);
  static const Color border = Color(0xff292929);
  static const Color primary = Color(0xffffffff);
  static const Color primaryDark = Color(0xffE5E5E5);
  static const Color success = Color(0xff22C55E);
  static const Color danger = Color(0xffEF4444);
  static const Color warning = Color(0xffF59E0B);
  static const Color info = Color(0xff60A5FA);

  static const Color secondary = textSecondary;
  static const Color softLavender = cardLight;
  static const Color rent = danger;
  static const Color bills = warning;
  static const Color savings = success;
  static const Color expenses = info;
  static const Color darkBackground = background;
  static const Color darkCard = card;
  static const Color darkBorder = border;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff181818), Color(0xff111111)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff000000), Color(0xff111111)],
  );

  static const LinearGradient cardPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff181818), Color(0xff111111)],
  );
}
