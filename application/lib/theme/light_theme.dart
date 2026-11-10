// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  useMaterial3: false,
  fontFamily: 'Roboto',
  primaryColor: AppColor.primaryColor,
  scaffoldBackgroundColor: AppColor.scaffoldBackground,
  disabledColor: AppColor.disabledColor,
  brightness: Brightness.light,
  hintColor: AppColor.hintColor,
  cardColor: AppColor.cardColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColor.primaryColor,
    brightness: Brightness.light,
    primary: AppColor.primaryColor,
    error: AppColor.errorColor,
  ),
  primarySwatch: AppColor.primarySwatchValueColor,
);

/// Brand palette taken from the Nazar-e-Alam logo:
/// saffron #F26B21, ring orange #F58220, cream #FFFDE7,
/// crimson #E8202A, green #00A650, near-black #1A1A1A.
class AppColor {
  static const int primarySwatchValue = 0xFFF26B21;

  // Surfaces
  static const Color themecolor         = Color(0xFFFFFDE7); // logo cream
  static const Color scaffoldBackground = Color(0xFFFFF9EE);
  static const Color cardColor          = Colors.white;

  // Brand
  static const Color primaryColor      = Color(0xFFF26B21); // saffron
  static const Color primaryColorLight = Color(0xFFF58220); // ring orange
  static const Color primaryColorDark  = Color(0xFFC9540F);
  static const Color primaryColorSoft  = Color(0xFFFFE9D9); // tint / bg
  static const Color goldColor         = Color(0xFFF58220);
  static const Color blueColor         = Color(0xFF2B2118); // warm near-black

  // New brand extras (use these in new UI)
  static const Color crimson   = Color(0xFFE8202A);
  static const Color success   = Color(0xFF00A650);
  static const Color ink       = Color(0xFF1A1A1A);
  static const Color cream     = Color(0xFFFFFDE7);

  // States / text
  static const Color disabledColor = Color(0xFFA7A29B);
  static const Color hintColor     = Color(0xFF1A1A1A);
  static const Color errorColor    = Color(0xFFE8202A);

  // Semantic pairs
  static const Color greenColorBG   = Color(0xFFE3F5EA);
  static const Color greenColorText = Color(0xFF00843F);

  static const Color tealColorBG    = Color(0xFFFDEBDD);
  static const Color tealColorText  = Color(0xFFB84A12);

  static const Color blueColorText  = Color(0xFFF58220);

  static const Color hoverBlueColor = Color(0xFFFFE9D9);

  static const MaterialColor primarySwatchValueColor =
      MaterialColor(primarySwatchValue, <int, Color>{
    50:  Color(0xFFFFF3EA),
    100: Color(0xFFFFE0CB),
    200: Color(0xFFFFC299),
    300: Color(0xFFFFA066),
    400: Color(0xFFF98440),
    500: Color(0xFFF26B21), // must match primarySwatchValue
    600: Color(0xFFDB5E1A),
    700: Color(0xFFC9540F),
    800: Color(0xFFA2430C),
    900: Color(0xFF7A3309),
  });
}