import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/theme/light_theme.dart';
import 'package:nazar_e_alam/theme/dark_theme.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/theme/modern_dark_theme.dart';

ThemeData getAppTheme(bool isDark) {
  final isClassic =
      Get.find<HomeLayoutController>().currentLayout.value ==
      HomeLayoutController.classic;

  if (isClassic) {
    return isDark ? dark : light;
  } else {
    return isDark ? modernDark : modernLight;
  }
}
