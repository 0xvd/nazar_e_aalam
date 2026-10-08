import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/helper/theme_helper.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

import 'controller/internet_check_controller.dart';
import 'controller/localization_controller.dart';

import 'controller/theme_controller.dart';
import 'helper/audio_service_helper.dart';
import 'helper/get_di.dart' as di;
import 'helper/route_helper.dart';
import 'util/messages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  // Initialize the AudioHandler
  await AudioServiceHelper.init();
  Map<String, Map<String, String>> languages = await di.init();
  runApp(MyApp(languages: languages));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  MyApp({super.key, required this.languages});

  final InternetController internetController = Get.put(InternetController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetX<HomeLayoutController>(
              builder: (layoutController) {
                return GetMaterialApp(
                  title: AppConstants.APP_NAME,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Get.key,
                  theme: getAppTheme(themeController.darkTheme),
                  locale: localizeController.locale,
                  initialRoute: RouteHelper.initial,
                  getPages: RouteHelper.routes,
                  defaultTransition: Transition.topLevel,
                  translations: Messages(languages: languages),
                  fallbackLocale: Locale(
                    AppConstants.languages[0].languageCode!,
                    AppConstants.languages[0].countryCode,
                  ),
                  transitionDuration: const Duration(milliseconds: 500),
                  builder: (context, child) {
                    Theme.of(context);

                    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                              bottom: Platform.isAndroid,
                              child: child!,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
