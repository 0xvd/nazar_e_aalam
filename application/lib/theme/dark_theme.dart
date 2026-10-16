// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  useMaterial3: false,
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFFAF8209),
  scaffoldBackgroundColor: const Color(0xFF1f1f1f),
  disabledColor: const Color(0xFF6f7275),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: Colors.black,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFAF8209),
    brightness: Brightness.dark,
    primary: const Color(0xFFAF8209),
    error: const Color(0xFFE84D4F),
  ),
  primarySwatch: AppColor.primarySwatchValueColor,
);

class AppColor {
  static const int primarySwatchValue = 0xFFAF8209;
  static const MaterialColor primarySwatchValueColor = MaterialColor(
    primarySwatchValue,
    <int, Color>{
      50: Color(primarySwatchValue),
      100: Color(primarySwatchValue),
      200: Color(primarySwatchValue),
      300: Color(primarySwatchValue),
      400: Color(primarySwatchValue),
      500: Color(primarySwatchValue),
      600: Color(primarySwatchValue),
      700: Color(primarySwatchValue),
      800: Color(primarySwatchValue),
      900: Color(primarySwatchValue),
    },
  );
}
