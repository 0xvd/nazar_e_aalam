// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

ThemeData modernLight = ThemeData(
  useMaterial3: false,
  fontFamily: 'Roboto',
  primaryColor: AppColorModern.primaryColor,
  scaffoldBackgroundColor: AppColorModern.scaffoldBackground,
  disabledColor: const Color(0xFFA0A4A8),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: AppColorModern.cardBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColorModern.primaryColor,
    brightness: Brightness.light,
    primary: AppColorModern.primaryColor,
    error: const Color(0xFFE84D4F),
  ),
  primarySwatch: AppColorModern.primarySwatchValueColor,
);

/// NOTE: The `emerald*` / `primaryGreen*` names are legacy — the palette
/// was re-themed from emerald green to a warm bronze/amber. Names are kept
/// for source compatibility; the values are what matter.
class AppColorModern {
  // Brand base — bronze. Also the 500 shade below.
  static const int primarySwatchValue = 0xFFC98232;

  static const Color primaryColor      = Color(0xFFC98232);
  static const Color primaryColorLight = Color(0xFFE69249); // lighter accent
  static const Color primaryColorDark  = Color(0xFFA96524);

  // "emerald*" — legacy names, now bronze tones
  static const Color emerald       = Color(0xFFC98232);
  static const Color emeraldDark   = Color(0xFFA96524);
  static const Color emeraldLight  = Color(0xFFE69249);
  static const Color emeraldSoftBg = Color(0xFFF6EBDD);

  // Surfaces
  static const Color scaffoldBackground = Color(0xFFFBF7EF);
  static const Color cardBackground     = Color(0xFFFFFDF8);

  // "primaryGreen*" — legacy names, now bronze tones
  static const Color primaryGreenDark  = Color(0xFFA96524);
  static const Color primaryGreen      = Color(0xFFC98232);
  static const Color primaryGreenLight = Color(0xFFE69249);
  static const Color accentGreen       = Color(0xFFB8752B);
  static const Color chipGreenBackground = Color(0xFFF6EBDD);

  // Text
  static const Color textPrimary      = Color(0xFF292923);
  static const Color textSecondary    = Color(0xFF77756C);
  static const Color textOnGreen      = Colors.white;
  static const Color textOnGreenMuted = Color(0xFFF5E6D0);

  // Tints
  static const Color tintGreen = Color(0xFFF6EBDD);
  static const Color tintCream = Color(0xFFF6EBDD);
  static const Color tintGray  = Color(0xFFECE9E2);
  static const Color tintBlue  = Color(0xFFE8E4DC);

  // Misc
  static const Color divider            = Color(0xFFE2DED5);
  static const Color progressTrack      = Color(0xFFE6E3DA);
  static const Color iconChipBackground = Color(0xFFF1EFE8);

  // Proper bronze swatch (light -> dark)
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

// class AppColorModern {
//   // static const int primarySwatchValue = 0xFF2E7D5B;
//   static const int primarySwatchValue = 0xFFffffe3;
//   // static const Color primaryColor = Color(0xFF2E7D5B);
//   static const Color primaryColor = Color(0xFFffffe3);

//   // Modern (emerald) home layout palette
//   static const Color emerald = Color(0xFF2E7D5B);
//   static const Color emeraldDark = Color(0xFF1B5E3F);
//   static const Color emeraldLight = Color(0xFF4FA980);
//   static const Color emeraldSoftBg = Color(0xFFF3F8F5);

//   // Backgrounds
//   static const Color scaffoldBackground = Color(0xFFF3F5EE);
//   static const Color cardBackground = Color(0xFFFFFFFF);

//   // Greens (prayer card + brand)
//   static const Color primaryGreenDark = Color(0xFF2F5233);
//   static const Color primaryGreen = Color(0xFF4C7A50);
//   static const Color primaryGreenLight = Color(0xFF6B9A6E);
//   static const Color accentGreen = Color(0xFF3B6B45);
//   static const Color chipGreenBackground = Color(0xFFEFF3EA);

//   // Text
//   static const Color textPrimary = Color(0xFF1E2A22);
//   static const Color textSecondary = Color(0xFF6B7570);
//   static const Color textOnGreen = Color(0xFFFFFFFF);
//   static const Color textOnGreenMuted = Color(0xFFDCE7DC);

//   // Feature card tints
//   static const Color tintGreen = Color(0xFFE3ECE0);
//   static const Color tintCream = Color(0xFFF6EEE0);
//   static const Color tintGray = Color(0xFFE9EAEC);
//   static const Color tintBlue = Color(0xFFE3EEF0);

//   // Misc
//   static const Color divider = Color(0xFFE3E6E0);
//   static const Color progressTrack = Color(0xFFE7EAE3);
//   static const Color iconChipBackground = Color(0xFFF1F3ED);

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