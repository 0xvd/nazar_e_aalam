// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  useMaterial3: false,
  fontFamily: 'Roboto',
  primaryColor: AppColor.primaryColorLight,
  scaffoldBackgroundColor: AppColor.scaffoldBackground,
  disabledColor: AppColor.disabledColor,
  brightness: Brightness.light,
  hintColor: AppColor.hintColor,
  cardColor: AppColor.cardColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColor.primaryColor,   // was #232f3e — now matches brand
    brightness: Brightness.light,
    primary: AppColor.primaryColor,     // was #232f3e — now matches brand
    error: AppColor.errorColor,
  ),
  primarySwatch: AppColor.primarySwatchValueColor,
);

class AppColor {
  // Brand base — used as the 500 shade of the swatch below.
  static const int primarySwatchValue = 0xFFFF7C1F;

  // Surfaces
  static const Color themecolor         = Color(0xFFFBF7EF);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);
  static const Color cardColor          = Colors.white;

  // Brand
  static const Color primaryColor      = Color(0xFFFF7C1F); // base orange
  static const Color primaryColorLight = Color(0xFFe69249); // lighter
  static const Color primaryColorDark  = Color(0xFFE06B15); // darker
  static const Color primaryColorSoft  = Color(0xFFFFE7D2); // tint / bg
  static const Color goldColor         = Color(0xFFFF7C1F);
  static const Color blueColor         = Color(0xFF315438);

  // States / text
  static const Color disabledColor = Color(0xFFA0A4A8);
  // static const Color hintColor     = Color(0xFF9F9F9F);
  static const Color hintColor     = Colors.black;
  static const Color errorColor    = Color(0xFFE84D4F);

  // Semantic pairs
  static const Color greenColorBG   = Color(0xFFE7EEE5);
  static const Color greenColorText = Color(0xFF47704C);

  static const Color tealColorBG    = Color(0xFFF6EBDD);
  static const Color tealColorText  = Color(0xFFA96524);

  static const Color blueColorText  = Color(0xFFD9A45B);

  static const Color hoverBlueColor = Color(0xFFF6EBDD);

  // Proper orange swatch (light -> dark)
  static const MaterialColor primarySwatchValueColor =
      MaterialColor(primarySwatchValue, <int, Color>{
    50:  Color(0xFFFFF3E6),
    100: Color(0xFFFFE7D2),
    200: Color(0xFFFFC99A),
    300: Color(0xFFFFB578),
    400: Color(0xFFFFA054),
    500: Color(0xFFFF7C1F), // base — must match primarySwatchValue
    600: Color(0xFFF06F17),
    700: Color(0xFFE06B15),
    800: Color(0xFFB85812),
    900: Color(0xFF8F4410),
  });
}

// class AppColor {
//   static const int primarySwatchValue = 0xFF292017;
//   static const Color themecolor = Color(0xFFfcffe3);
//   static const Color primaryColor = Color(0xFF292017);
//   static const Color cardColor = Colors.white;
//   static const Color blueColor = Color(0xFF1e2a40);
//   static const Color goldColor = Color(0xFFf9a825);
//   static const Color greenColorBG = Color(0xFF1a3a2a);
//   static const Color greenColorText = Color(0xFF81c784);

//   static const Color tealColorBG = Color(0xFF80cbc4);
//   static const Color tealColorText = Color(0xFF1c3030);
//   static const Color blueColorText = Color(0xFF90caf9);

//   static const MaterialColor primarySwatchValueColor =
//       MaterialColor(primarySwatchValue, <int, Color>{
//         50: Color(primarySwatchValue),
//         100: Color(primarySwatchValue),
//         200: Color(primarySwatchValue),
//         300: Color(primarySwatchValue),
//         400: Color(primarySwatchValue),
//         500: Color(primarySwatchValue),
//         600: Color(primarySwatchValue),
//         700: Color(primarySwatchValue),
//         800: Color(primarySwatchValue),
//         900: Color(primarySwatchValue),
//       });
//   static const Color hoverBlueColor = Color(0xFFEEEDFD);
// }
