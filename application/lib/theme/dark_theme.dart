// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  useMaterial3: false,
  fontFamily: 'Roboto',
  primaryColor: AppColor.primaryColor,
  scaffoldBackgroundColor: AppColor.scaffoldBackground,
  disabledColor: const Color(0xFF7A6F65),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFC9B8A6),
  cardColor: AppColor.cardColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColor.primaryColor,
    brightness: Brightness.dark,
    primary: AppColor.primaryColor,
    error: const Color(0xFFFF4D55),
  ),
  primarySwatch: AppColor.primarySwatchValueColor,
);

// NOTE: same class name as in light_theme.dart (kept so existing imports
// keep working). Only the values used in dark mode live here.
class AppColor {
  static const int primarySwatchValue = 0xFFF26B21;

  static const Color primaryColor      = Color(0xFFF26B21);
  static const Color scaffoldBackground = Color(0xFF15100C);
  static const Color cardColor          = Color(0xFF221A14);

  static const MaterialColor primarySwatchValueColor =
      MaterialColor(primarySwatchValue, <int, Color>{
    50:  Color(0xFFFFF3EA),
    100: Color(0xFFFFE0CB),
    200: Color(0xFFFFC299),
    300: Color(0xFFFFA066),
    400: Color(0xFFFF8A4C),
    500: Color(0xFFF26B21),
    600: Color(0xFFDB5E1A),
    700: Color(0xFFC9540F),
    800: Color(0xFFA2430C),
    900: Color(0xFF7A3309),
  });
}