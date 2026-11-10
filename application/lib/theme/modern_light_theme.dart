// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// NOTE: variable name assumed to be `modernLight`. Rename if yours differs.
ThemeData modernLight = ThemeData(
  useMaterial3: false,
  fontFamily: 'Roboto',
  primaryColor: AppColorModern.primaryColor,
  scaffoldBackgroundColor: AppColorModern.scaffoldBackground,
  disabledColor: AppColorModern.disabledColor,
  brightness: Brightness.light,
  hintColor: AppColorModern.hintColor,
  cardColor: AppColorModern.cardBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColorModern.primaryColor,
    brightness: Brightness.light,
    primary: AppColorModern.primaryColor,
    error: AppColorModern.errorColor,
  ),
  primarySwatch: AppColorModern.primarySwatchValueColor,
);

/// Light counterpart of `AppColorModernDark`. Cream surfaces, saffron accent.
class AppColorModern {
  static const int primarySwatchValue = 0xFFF26B21;

  static const Color primaryColor      = Color(0xFFF26B21);
  static const Color primaryColorLight = Color(0xFFFF8A4C);
  static const Color primaryColorDark  = Color(0xFFC9540F);

  // legacy names
  static const Color emerald       = Color(0xFFF26B21);
  static const Color emeraldDark   = Color(0xFFC9540F);
  static const Color emeraldLight  = Color(0xFFFF8A4C);
  static const Color emeraldSoftBg = Color(0xFFFFE9D9);

  // Surfaces
  static const Color scaffoldBackground = Color(0xFFFFF9EE);
  static const Color cardBackground     = Colors.white;

  // legacy names
  static const Color primaryGreenDark    = Color(0xFFC9540F);
  static const Color primaryGreen        = Color(0xFFF26B21);
  static const Color primaryGreenLight   = Color(0xFFFF8A4C);
  static const Color accentGreen         = Color(0xFFF58220);
  static const Color chipGreenBackground = Color(0xFFFFE9D9);

  // Text
  static const Color textPrimary      = Color(0xFF1A1A1A);
  static const Color textSecondary    = Color(0xFF6B5E52);
  static const Color textOnGreen      = Colors.white;
  static const Color textOnGreenMuted = Color(0xFFFFE3CC);

  // States
  static const Color disabledColor = Color(0xFFA7A29B);
  static const Color hintColor     = Color(0xFF6B5E52);
  static const Color errorColor    = Color(0xFFE8202A);

  // Tints
  static const Color tintGreen = Color(0xFFE3F5EA);
  static const Color tintCream = Color(0xFFFFFDE7);
  static const Color tintGray  = Color(0xFFF4EEE4);
  static const Color tintBlue  = Color(0xFFFFF3EA);

  // Misc
  static const Color divider            = Color(0xFFEADFD0);
  static const Color progressTrack      = Color(0xFFF1E6D8);
  static const Color iconChipBackground = Color(0xFFFFF0E2);

  // Glass (new)
  static const Color glassFill   = Color(0x66FFFFFF);
  static const Color glassBorder = Color(0x99FFFFFF);

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