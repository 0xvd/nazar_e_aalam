// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

// import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:nazar_e_alam/controller/ai_assistant_controller.dart';
import 'package:nazar_e_alam/controller/alphabet_controller.dart';
import 'package:nazar_e_alam/controller/audio_player_controller.dart';
import 'package:nazar_e_alam/controller/bookmark_controller.dart';
import 'package:nazar_e_alam/controller/category_controller.dart';
import 'package:nazar_e_alam/controller/dhikr_controller.dart';
// import 'package:nazar_e_alam/controller/donation_controller.dart';
import 'package:nazar_e_alam/controller/dua_controller.dart';
import 'package:nazar_e_alam/controller/hadith_controller.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
// import 'package:nazar_e_alam/controller/islamic_name_controller.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/controller/nearby_mosque_controller.dart';
import 'package:nazar_e_alam/controller/noti_sound_controller.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/prayer_time_adjustment.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_milestone_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/controller/splash_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/controller/wallpaper_controller.dart';
import 'package:nazar_e_alam/controller/zakat_calculator_controller.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
// import 'package:nazar_e_alam/data/model/response/language_model.dart';
// import 'package:nazar_e_alam/data/repository/ai_assistant_repo.dart';
import 'package:nazar_e_alam/data/repository/dikir_list_repo.dart';
// import 'package:nazar_e_alam/data/repository/donation_repo.dart';
import 'package:nazar_e_alam/data/repository/dua_list_repo.dart';
// import 'package:nazar_e_alam/data/repository/islamic_name_repo.dart';
import 'package:nazar_e_alam/data/repository/quran_setting_repo.dart';
import 'package:nazar_e_alam/data/repository/sifatname_list_repo.dart';
import 'package:nazar_e_alam/data/repository/splash_repo.dart';
import 'package:nazar_e_alam/data/repository/wallpaper_repo.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

Future<Map<String, Map<String, String>>> init(SharedPreferences sharedPreferences) async {
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(
    () => ApiClient(
      appBaseUrl: AppConstants.BASE_URL,
      sharedPreferences: Get.find(),
    ),
  );

  // Repository
  Get.lazyPut(
    () => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
  );
  Get.lazyPut(
    () => DuaRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
  );
  Get.lazyPut(
    () => DhikrRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
  );
  Get.lazyPut(
    () => QuranRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
  );
  Get.lazyPut(
    () =>
        QuranSettingsRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
    fenix: true,
  );
  // Get.lazyPut(
  //   () => DonationRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
  // );
  Get.lazyPut(
    () => WallpaperRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
  );
  // Get.lazyPut(() => IslamicNameRepo());
  // Get.lazyPut(() => AiAssistantRepo(), fenix: true);

  //new controller
  Get.lazyPut(
    () => LocalizationController(
      sharedPreferences: Get.find(),
      apiClient: Get.find(),
    ),
    fenix: true,
  );
  Get.lazyPut(() => DhikrController(dhikrRepo: Get.find()));
  Get.lazyPut(() => DuaController(duaRepo: Get.find()));
  // Get.lazyPut(() => DonationController(donationRepo: Get.find()));
  Get.lazyPut(() => QuranController(quranRepo: Get.find()));
  Get.lazyPut(() => PrayerTimeController(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => NotiSoundController());
  Get.lazyPut(() => AudioPlayerController(apiClient: Get.find()));
  Get.lazyPut(() => WallPaperController(wallpaperRepo: Get.find()));
  Get.lazyPut(() => AlphabetController());
  Get.lazyPut(() => PrayerTimeAdjustmentController(), fenix: true);
  Get.lazyPut(() => InternetController(), fenix: true);
  // Get.lazyPut(() => IslamicNameController());
  // Get.lazyPut(
  //   () => AiAssistantController(assistantRepo: Get.find()),
  //   fenix: true,
  // );
  Get.lazyPut(
    () => HomeLayoutController(sharedPreferences: Get.find()),
    fenix: true,
  );
  Get.lazyPut(
    () => QuranMilestoneController(sharedPreferences: Get.find()),
    fenix: true,
  );

  // old controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => HadithController());
  Get.lazyPut(() => NearbyMosqueController());
  Get.lazyPut(
    () => SettingsController(quranSettingRepo: Get.find()),
    fenix: true,
  );
  Get.lazyPut(() => BookMarkController());
  Get.lazyPut(() => CategoryListController());
  Get.lazyPut(() => ZakatCalculatorController());
  return {};
}

/// Loads every language JSON.
/// NOTE: This is the slow path (~1000ms on low-end devices). Prefer
/// `loadActiveLanguage()` for startup. Kept for compatibility.
Future<Map<String, Map<String, String>>> loadLanguages() async {
  final languages = <String, Map<String, String>>{};
  for (final languageModel in AppConstants.languages) {
    final jsonString = await rootBundle.loadString(
      'assets/language/${languageModel.languageCode}.json',
    );
    final mappedJson = json.decode(jsonString) as Map<String, dynamic>;
    final translations = <String, String>{};
    for (final entry in mappedJson.entries) {
      translations[entry.key] = entry.value.toString();
    }
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
        translations;
  }
  return languages;
}

/// Loads ONE language JSON — the one the user currently has selected.
/// This is what `_Bootstrap` awaits; it's ~10x faster than `loadLanguages()`.
Future<Map<String, Map<String, String>>> loadActiveLanguage() async {
  final prefs = Get.find<SharedPreferences>();

  // Read the saved language/country. Adjust the keys if your
  // `LocalizationController` uses different names.
  final code = prefs.getString(AppConstants.LANGUAGE_CODE) ??
      AppConstants.languages.first.languageCode!;
  final country = prefs.getString(AppConstants.COUNTRY_CODE) ??
      AppConstants.languages.first.countryCode!;

  final map = await loadLanguage(code);
  return {'${code}_$country': map};
}

/// Loads a single language JSON by code. Used by `loadActiveLanguage()` and
/// by the language-switcher at runtime.
Future<Map<String, String>> loadLanguage(String languageCode) async {
  final jsonString = await rootBundle.loadString(
    'assets/language/$languageCode.json',
  );
  final decoded = json.decode(jsonString) as Map<String, dynamic>;
  final out = <String, String>{};
  for (final entry in decoded.entries) {
    out[entry.key] = entry.value.toString();
  }
  return out;
}