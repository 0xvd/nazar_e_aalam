import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/helper/theme_helper.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

import 'controller/internet_check_controller.dart';
import 'helper/audio_service_helper.dart';
import 'helper/get_di.dart' as di;
import 'helper/route_helper.dart';
import 'util/messages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  await di.init();
  await AudioServiceHelper.init();
  Map<String, Map<String, String>> languages = await di.init();

  // Register InternetController in advance
  Get.put(InternetController());

  final layoutController = Get.find<HomeLayoutController>();
  final lightTheme = getAppTheme(layoutController.currentLayout.value, false);
  final darkTheme = getAppTheme(layoutController.currentLayout.value, true);

  runApp(MyApp(
    languages: languages,
    lightTheme: lightTheme,
    darkTheme: darkTheme,
  ));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const MyApp({
    super.key,
    required this.languages,
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localizeController = Get.find<LocalizationController>();

    return GetMaterialApp(
      title: AppConstants.APP_NAME,
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      // NOTE: `theme:` and `darkTheme:` are intentionally NOT passed here.
      // Passing them makes GetMaterialApp wrap everything in Flutter's
      // AnimatedTheme, which color-interpolates every widget on every
      // theme change — that is the source of the lag on your 60Hz device.
      // Instead, the active theme is applied instantly below in `builder`.
      themeMode: themeController.darkTheme ? ThemeMode.dark : ThemeMode.light,
      locale: localizeController.locale,
      initialRoute: RouteHelper.initial,
      getPages: RouteHelper.routes,
      defaultTransition: Transition.topLevel,
      translations: Messages(languages: languages),
      fallbackLocale: Locale(
        AppConstants.languages[0].languageCode!,
        AppConstants.languages[0].countryCode!,
      ),
      transitionDuration: const Duration(milliseconds: 500),
      builder: (context, child) {
        // Pick the correct ThemeData and apply it INSTANTLY (no animation).
        // This is a plain `Theme` widget, not `AnimatedTheme`, so the swap
        // is a single frame — zero interpolation, zero lag — while every
        // other animation in the app (page transitions, ripples, etc.)
        // keeps working exactly as before.
        final activeTheme =
            themeController.darkTheme ? darkTheme : lightTheme;

        return Theme(
          data: activeTheme,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => SafeArea(
                    top: false,
                    bottom: !kIsWeb && Platform.isAndroid,
                    child: child!,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}