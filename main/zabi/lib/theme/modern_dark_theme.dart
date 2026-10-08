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

/// Dark counterpart of `AppColorModern`. Same bronze/amber brand,
/// inverted surfaces & text for night mode.
class AppColorModernDark {
  // Brand base — bronze. Also the 500 shade below.
  static const int primarySwatchValue = 0xFFC98232;

  static const Color primaryColor      = Color(0xFFC98232);
  static const Color primaryColorLight = Color(0xFFE69249); // lighter accent
  static const Color primaryColorDark  = Color(0xFFA96524);

  // "emerald*" — legacy names, now bronze tones
  static const Color emerald       = Color(0xFFC98232);
  static const Color emeraldDark   = Color(0xFFA96524);
  static const Color emeraldLight  = Color(0xFFE69249);
  static const Color emeraldSoftBg = Color(0xFF2A231A);

  // Surfaces
  static const Color scaffoldBackground = Color(0xFF1E1E1E);
  static const Color cardBackground     = Color(0xFF262626);

  // "primaryGreen*" — legacy names, now bronze tones
  static const Color primaryGreenDark  = Color(0xFFA96524);
  static const Color primaryGreen      = Color(0xFFC98232);
  static const Color primaryGreenLight = Color(0xFFE69249);
  static const Color accentGreen       = Color(0xFFB8752B);
  static const Color chipGreenBackground = Color(0xFF2A231A);

  // Text
  static const Color textPrimary      = Color(0xFFF1EFE8);
  static const Color textSecondary    = Color(0xFFBEBEBE);
  static const Color textOnGreen      = Colors.white;
  static const Color textOnGreenMuted = Color(0xFFF5E6D0);

  // States
  static const Color disabledColor = Color(0xFF6F7275);
  static const Color hintColor     = Color(0xFFBEBEBE);
  static const Color errorColor    = Color(0xFFE84D4F);

  // Tints (dark variants)
  static const Color tintGreen = Color(0xFF2A231A);
  static const Color tintCream = Color(0xFF2A231A);
  static const Color tintGray  = Color(0xFF2C2C2C);
  static const Color tintBlue  = Color(0xFF262626);

  // Misc
  static const Color divider            = Color(0xFF3A3A3A);
  static const Color progressTrack      = Color(0xFF333333);
  static const Color iconChipBackground = Color(0xFF2C2C2C);

  // Proper bronze swatch (light -> dark) — same ramp as light theme
  static const MaterialColor primarySwatchValueColor =
      MaterialColor(primarySwatchValue, <int, Color>{
    50:  Color(0xFFFBF3E7),
    100: Color(0xFFF6E7CE),
    200: Color(0xFFEFCF9C),
    300: Color(0xFFE3B06A),
    400: Color(0xFFE69249), // lighter accent
    500: Color(0xFFC98232), // base — must match primarySwatchValue
    600: Color(0xFFB8752B),
    700: Color(0xFFA96524),
    800: Color(0xFF8A511C),
    900: Color(0xFF6B3E15),
  });
}


// import 'package:flutter/material.dart';

// ThemeData modernDark = ThemeData(
//   useMaterial3: false,
//   fontFamily: 'Roboto',
//   primaryColor: const Color(0xFF4FA980),
//   scaffoldBackgroundColor: const Color.fromARGB(255, 49, 49, 49),
//   disabledColor: const Color(0xFF6F7275),
//   brightness: Brightness.dark,
//   hintColor: const Color(0xFFBEBEBE),
//   cardColor: const Color.fromARGB(255, 38, 38, 38),
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: const Color(0xFF4FA980),
//     brightness: Brightness.dark,
//     primary: const Color(0xFF4FA980),
//     error: const Color(0xFFE84D4F),
//   ),
//   primarySwatch: AppColorModernDark.primarySwatchValueColor,
// );

// class AppColorModernDark {
//   static const int primarySwatchValue = 0xFF4FA980;
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
// }
