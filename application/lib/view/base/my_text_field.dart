import 'package:flutter/material.dart';

import '../../util/dimensions.dart';
import '../../util/styles.dart';

InputDecoration getTextInputDecoration(BuildContext context) {
  final theme = Theme.of(context);
  final dark = theme.brightness == Brightness.dark;
  final primary = theme.primaryColor;
  final error = theme.colorScheme.error;
  final idle = dark ? const Color(0xFF3A2E24) : const Color(0xFFEADFD0);

  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    filled: true,
    fillColor: theme.cardColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: robotoMedium.copyWith(
      color: primary,
      fontSize: Dimensions.FONT_SIZE_DEFAULT,
    ),
    hintStyle: robotoRegular.copyWith(
      color: theme.hintColor.withValues(alpha: 0.6),
      fontSize: Dimensions.FONT_SIZE_DEFAULT,
    ),
    border: border(idle),
    enabledBorder: border(idle),
    disabledBorder: border(idle),
    focusedBorder: border(primary, 1.6),
    errorBorder: border(error),
    focusedErrorBorder: border(error, 1.6),
  );
}