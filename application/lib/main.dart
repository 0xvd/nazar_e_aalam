import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/helper/theme_helper.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

import 'controller/internet_check_controller.dart';
import 'controller/package_prayer_time_controller.dart';
import 'helper/audio_service_helper.dart';
import 'helper/get_di.dart' as di;
import 'helper/route_helper.dart';
import 'util/messages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    FlutterDisplayMode.setHighRefreshRate().catchError((_) => <DisplayMode>[]);
  }

  // Paints the splash frame immediately. Nothing blocks before this.
  runApp(const _Bootstrap());
}

/// Shows the branded splash (logo + app name) while `SharedPreferences`,
/// DI registration, and the active language JSON load behind it.
///
/// Timeline on a Redmi Note 10 (cold start):
///   0–200 ms   MIUI black window (system, unavoidable)
///   200 ms     Flutter splash frame with logo fades in
///   200–1200ms SharedPreferences (~1s) runs BEHIND the visible splash
///   1200 ms    MyApp mounts → home
///
/// The 1-second SharedPreferences read still happens — but the user sees
/// the logo, not a black screen, while it runs.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  Future<_BootConfig>? _ready;
  bool _logoReady = false;

  @override
  void initState() {
    super.initState();
    // Wait one frame so the splash (with logo) paints first, THEN start
    // the slow work. This is the key to hiding SharedPreferences.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final future = _boot(); // start work first
      setState(() {
        _ready = future; // then assign synchronously
      });
    });
  }

  Future<_BootConfig> _boot() async {
    // Audio service runs fully in the background — never blocks the splash.
    unawaited(
      AudioServiceHelper.init().catchError((Object e, StackTrace st) {
        debugPrint('AudioServiceHelper init failed: $e\n$st');
      }),
    );

    // Precache the logo so the visible splash actually shows it.
    await precacheImage(const AssetImage(Images.APP_LOGO), context);
    if (!mounted) throw StateError('_Bootstrap unmounted during boot');
    setState(() => _logoReady = true);

    // Now do the slow work — the logo is already on screen.
    final prefs = await SharedPreferences.getInstance();
    await di.init(prefs);

    Get.put(InternetController());

    // Kick off location in the background — splash shouldn't wait on it.
    unawaited(
      Get.find<PrayerTimeController>().getLocation().catchError((_) {}),
    );

    // Fast path: load only the currently-selected language JSON.
  final languages = await di.loadLanguages();

    final layout = Get.find<HomeLayoutController>().currentLayout.value;
    final light = getAppTheme(layout, false);
    final dark = getAppTheme(layout, true);

    return _BootConfig(languages: languages, light: light, dark: dark);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _ready;
    if (cfg == null) {
      // First frame: splash without logo yet (logo fades in once precached).
      return _buildSplash(context);
    }
    return FutureBuilder<_BootConfig>(
      future: cfg,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done || snap.hasError) {
          // Still booting — keep the splash on screen. This is what covers
          // the ~1s SharedPreferences read.
          return _buildSplash(context);
        }
        final data = snap.data!;
        return MyApp(
          languages: data.languages,
          lightTheme: data.light,
          darkTheme: data.dark,
        );
      },
    );
  }

  Widget _buildSplash(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: AnimatedOpacity(
            opacity: _logoReady ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  Images.APP_LOGO,
                  height: 120,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                  AppConstants.APP_NAME,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BootConfig {
  final Map<String, Map<String, String>> languages;
  final ThemeData light;
  final ThemeData dark;
  _BootConfig({
    required this.languages,
    required this.light,
    required this.dark,
  });
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
      themeMode: themeController.darkTheme ? ThemeMode.dark : ThemeMode.light,
      locale: localizeController.locale,
      // Splash was shown by `_Bootstrap`, so go straight to home.
      initialRoute: RouteHelper.bottomNavbar,
      getPages: RouteHelper.routes,
      defaultTransition: Transition.topLevel,
      translations: Messages(languages: languages),
      fallbackLocale: Locale(
        AppConstants.languages[0].languageCode!,
        AppConstants.languages[0].countryCode!,
      ),
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, child) {
        final layout = Get.find<HomeLayoutController>().currentLayout.value;
        final activeTheme = themeController.darkTheme
            ? getAppTheme(layout, true)
            : getAppTheme(layout, false);

        return Theme(
          data: activeTheme,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
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
