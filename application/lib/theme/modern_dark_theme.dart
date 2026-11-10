// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

ThemeData modernDark = ThemeData(
  useMaterial3: false,
  fontFamily: 'Roboto',
  primaryColor: AppColorModernDark.primaryColor,
  scaffoldBackgroundColor: AppColorModernDark.scaffoldBackground,
  disabledColor: AppColorModernDark.disabledColor,
  brightness: Brightness.dark,
  hintColor: AppColorModernDark.hintColor,
  cardColor: AppColorModernDark.cardBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColorModernDark.primaryColor,
    brightness: Brightness.dark,
    primary: AppColorModernDark.primaryColor,
    error: AppColorModernDark.errorColor,
  ),
  primarySwatch: AppColorModernDark.primarySwatchValueColor,
);

/// Dark counterpart of `AppColorModern`. Warm black surfaces with the
/// logo's saffron as the accent. Legacy names (emerald*, primaryGreen*)
/// are kept so existing screens keep compiling.
class AppColorModernDark {
  static const int primarySwatchValue = 0xFFF26B21;

  static const Color primaryColor      = Color(0xFFF26B21);
  static const Color primaryColorLight = Color(0xFFFF8A4C);
  static const Color primaryColorDark  = Color(0xFFC9540F);

  // legacy names
  static const Color emerald       = Color(0xFFF26B21);
  static const Color emeraldDark   = Color(0xFFC9540F);
  static const Color emeraldLight  = Color(0xFFFF8A4C);
  static const Color emeraldSoftBg = Color(0xFF2B1D13);

  // Surfaces
  static const Color scaffoldBackground = Color(0xFF15100C);
  static const Color cardBackground     = Color(0xFF221A14);

  // legacy names
  static const Color primaryGreenDark    = Color(0xFFC9540F);
  static const Color primaryGreen        = Color(0xFFF26B21);
  static const Color primaryGreenLight   = Color(0xFFFF8A4C);
  static const Color accentGreen         = Color(0xFFF58220);
  static const Color chipGreenBackground = Color(0xFF2B1D13);

  // Text
  static const Color textPrimary      = Color(0xFFFFF4E8);
  static const Color textSecondary    = Color(0xFFC9B8A6);
  static const Color textOnGreen      = Colors.white;
  static const Color textOnGreenMuted = Color(0xFFFFE3CC);

  // States
  static const Color disabledColor = Color(0xFF7A6F65);
  static const Color hintColor     = Color(0xFFC9B8A6);
  static const Color errorColor    = Color(0xFFFF4D55);

  // Tints
  static const Color tintGreen = Color(0xFF2B1D13);
  static const Color tintCream = Color(0xFF2B2216);
  static const Color tintGray  = Color(0xFF2A221B);
  static const Color tintBlue  = Color(0xFF221A14);

  // Misc
  static const Color divider            = Color(0xFF3A2E24);
  static const Color progressTrack      = Color(0xFF33291F);
  static const Color iconChipBackground = Color(0xFF2A221B);

  // Glass (new)
  static const Color glassFill   = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);

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