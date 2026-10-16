import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  ThemeController({required this.sharedPreferences}) {
    _darkTheme = sharedPreferences.getBool(AppConstants.THEME) ?? false;
  }

  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    sharedPreferences.setBool(AppConstants.THEME, _darkTheme);
    Get.changeThemeMode(_darkTheme ? ThemeMode.dark : ThemeMode.light);
    update();
  }
}
