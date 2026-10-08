// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../util/dimensions.dart';
import '../../util/styles.dart';

InputDecoration getTextInputDecoration(BuildContext context) {
  return InputDecoration(
    labelStyle: robotoMedium.copyWith(
      color: Theme.of(context).primaryColor,
      fontSize: Dimensions.FONT_SIZE_DEFAULT,
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        // width: 1,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 1,
      ),
    ),
  );
}
